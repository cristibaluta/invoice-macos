//
//  ReportState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine
import SwiftCSV

class ReportInteractor {

    private let repository: Repository
    private let project: Project
    private let reportsInteractor: ReportsInteractor

    init (repository: Repository, project: Project, reportsInteractor: ReportsInteractor) {
        self.repository = repository
        self.project = project
        self.reportsInteractor = reportsInteractor
    }

    func buildHtml (data: InvoiceData) -> AnyPublisher<String, Never> {

        let reports: [Report] = data.reports.map({
            Report(project_name: $0.project_name,
                   group: $0.group,
                   description: $0.description,
                   duration: $0.duration)
        })
        let allProjects: [ReportProject] = projects(from: reports, isOn: true)

        return readReportTemplates()
            .map { templates in
                // template_report
                // template_report_project
                // template_report_row

                var template = templates.0
                let templateProject = templates.1
                let templateRow = templates.2

                let dict = data.toDictionary()

                for (key, value) in dict {
                    if key == "amount_total" || key == "amount_total_vat", let amount = Decimal(string: value as? String ?? "") {
                        // Format the money values
                        template = template.replacingOccurrences(of: "::\(key)::", with: "\(amount.stringValue_grouped2)")
                    }
                    else if key == "invoice_date", let date = Date(yyyyMMdd: value as? String ?? "") {
                        template = template.replacingOccurrences(of: "::\(key)::", with: "\(date.mediumDate)")
                    }
                    else if key == "invoiced_period", let date = Date(yyyyMMdd: value as? String ?? "") {
                        template = template.replacingOccurrences(of: "::invoiced_month::", with: "\(date.fullMonthName)")
                        template = template.replacingOccurrences(of: "::invoiced_year::", with: "\(date.year)")
                    }
                    else if key == "invoice_nr" {
                        // Prefix the invoice nr with zeroes
                        template = template.replacingOccurrences(of: "::\(key)::", with: data.invoice_nr.prefixedWith0)
                    }
                    else if key == "contractor" || key == "client", let dic = value as? [String: Any] {
                        // Contractor and client have this keywords as prefix
                        for (k, v) in dic {
                            template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                        }
                    }
                    else {
                        template = template.replacingOccurrences(of: "::\(key)::", with: "\(value)")
                    }
                }

                // Calculate the total amount of units
                let units = data.products.reduce(0.0) { u, product in
                    return u + product.units
                }
                template = template.replacingOccurrences(of: "::units::", with: units.stringValue_grouped2)

                let projects = self.reportsInteractor.groupReports(reports, duration: units)

                /// Add rows
                var projectsHtml = ""
                // Iterate over projects
                for (projectName, groups) in projects {
                    guard allProjects.first(where: {$0.name == projectName})?.isOn == true else {
                        continue
                    }
                    var project = templateProject.replacingOccurrences(of: "::project_name::", with: projectName)
                    var rowsHtml = ""

                    // Iterate over groups
                    for (groupName, reports) in groups {
                        if groupName.isEmpty {
                            // No group, add each report as a new table row
                            for report in reports {
                                var row = templateRow
                                row = row.replacingOccurrences(of: "::task::", with: report.description)
                                row = row.replacingOccurrences(of: "::duration::", with: report.duration.stringValue_grouped2)
                                rowsHtml += row
                            }
                        } else {
                            // Group found, add each report grouped together in a single row
                            var groupedTasksHtml = "<p>\(groupName):</p><ul>"
                            var duration: Decimal = 0.0
                            for report in reports {
                                groupedTasksHtml += "<li>\(report.description)</li>"
                                duration += report.duration
                            }
                            groupedTasksHtml += "</ul>"

                            var row = templateRow
                            row = row.replacingOccurrences(of: "::task::", with: groupedTasksHtml)
                            row = row.replacingOccurrences(of: "::duration::", with: duration.stringValue_grouped2)
                            rowsHtml += row
                        }
                    }

                    project = project.replacingOccurrences(of: "::rows::", with: rowsHtml)
                    projectsHtml += project
                }

                template = template.replacingOccurrences(of: "::projects::", with: projectsHtml)
                template = template.replacingOccurrences(of: "::month::", with: data.date.fullMonthName)
                template = template.replacingOccurrences(of: "::year::", with: "\(data.date.year)")

                return template
            }
            .eraseToAnyPublisher()
    }

    func save (data: InvoiceData, pdfData: Data?) -> AnyPublisher<Invoice, Never> {
        
        // Generate folder if none exists
        let invoiceNr = "\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
        let invoiceName = "\(data.date.yyyyMMdd)-\(invoiceNr)"

        let invoicePath = "\(project.name)/\(invoiceName)"

        // Create folder if does not exist
        let writeFolderPublisher = repository.writeFolder(at: invoicePath)

        // Save json
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(data)
        let invoiceJsonPath = "\(invoicePath)/data.json"
        let writeJsonPublisher = repository.writeFile(jsonData, at: invoiceJsonPath)

        // Save pdf
        let pdfName = "Report-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
        let pdfPath = "\(invoicePath)/\(pdfName)"
        let writePdfPublisher = repository.writeFile(pdfData!, at: pdfPath)

        let publisher = Publishers.Zip3(writeFolderPublisher, writeJsonPublisher, writePdfPublisher)
            .map { x in
                return Invoice(date: data.date, invoiceNr: invoiceNr, name: invoiceName)
            }

        return publisher.eraseToAnyPublisher()
    }

    func readCsv (at fileUrl: URL) -> ([Report], [ReportProject]) {

        var allReports: [Report] = []
        var allProjects: [ReportProject] = []

        do {
            let csv = try CSV(url: fileUrl, delimiter: ";")
            try csv.enumerateAsDict { dict in
                guard let projectName = dict["Project Name"], !projectName.isEmpty else {
                    return
                }
                let report = Report(project_name: projectName,
                                    group: dict["Component"] ?? "",
                                    description: dict["Work Description"] ?? "",
                                    duration: Decimal(Double(dict["Hours"]?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0))

                // Find duplicates and add times together
                var foundDuplicate = false
                for i in 0..<allReports.count {
                    if allReports[i].description == report.description {
                        allReports[i].duration += report.duration
                        foundDuplicate = true
                        break
                    }
                }
                if !foundDuplicate {
                    allReports.append(report)
                }
            }

            allProjects = projects(from: allReports, isOn: true)
        } catch {
            print(error)
        }
        return (allReports, allProjects)
    }

    private func readReportTemplates() -> AnyPublisher<(String, String, String), Never> {

        let templates = "\(project.name)/templates"

        let t1 = repository
            .readFile(at: "\(templates)/template_report.html")
            .map { String(decoding: $0, as: UTF8.self) }

        let t2 = repository
            .readFile(at: "\(templates)/template_report_project.html")
            .map { String(decoding: $0, as: UTF8.self) }

        let t3 = repository
            .readFile(at: "\(templates)/template_report_row.html")
            .map { String(decoding: $0, as: UTF8.self) }

        let publisher = Publishers.Zip3(t1, t2, t3).eraseToAnyPublisher()

        return publisher
    }

    private func projects (from reports: [Report], isOn: Bool) -> [ReportProject] {
        var arr = [ReportProject]()
        for report in reports {
            if !arr.contains(where: { $0.name == report.project_name }) {
                arr.append(ReportProject(name: report.project_name, isOn: isOn))
            }
        }
        return arr
    }
}
