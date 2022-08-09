//
//  ReportsInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 17.07.2022.
//

import Foundation
import Combine

class ReportsInteractor {

    let repository: Repository

    init (repository: Repository) {
        self.repository = repository
    }

    func readReportTemplates (in project: Project) -> AnyPublisher<(String, String, String), Never> {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let projectUrl = documentsDirectory.appendingPathComponent(project.name)
        let templatesUrl = projectUrl.appendingPathComponent("templates")

        let t1 = repository
            .readFile(at: templatesUrl.appendingPathComponent("template_report.html"))
            .map { String(decoding: $0, as: UTF8.self) }

        let t2 = repository
            .readFile(at: templatesUrl.appendingPathComponent("template_report_project.html"))
            .map { String(decoding: $0, as: UTF8.self) }

        let t3 = repository
            .readFile(at: templatesUrl.appendingPathComponent("template_report_row.html"))
            .map { String(decoding: $0, as: UTF8.self) }

        let publisher = Publishers.Zip3(t1, t2, t3).eraseToAnyPublisher()

        return publisher
    }

    let durationStep: Decimal = 0.5

    func groupReports (_ reports: [Report], duration: Decimal) -> [String: [String: [Report]]] {

        let originalDuration: Decimal = reports.reduce(0) { partialResult, report in
            return partialResult + report.duration
        }
        let extraDuration = duration - originalDuration

        // Group reports by projects then by groups
        var projects = [String: [String: [Report]]]()
        var nrOfReports: Decimal = 0

        for report in reports {
            var groups = projects[report.project_name] ?? [:]
            var groupReports = groups[report.group] ?? []
            groupReports.append(report)
            groups[report.group] = groupReports
            projects[report.project_name] = groups
            nrOfReports += 1
        }

        // Adjust durations
        guard extraDuration != 0 else {
            return projects
        }
        let extraDurationPerReport: Decimal = (extraDuration / nrOfReports).rounded(.down)
        var extraDurationUsed: Decimal = 0

        for (projectName, groups) in projects {
            for (groupName, reports) in groups {
                for i in 0..<reports.count {
                    let reportDuration = projects[projectName]![groupName]![i].duration
                    if reportDuration + extraDurationPerReport < 0.5 {
                        extraDurationUsed += (reportDuration - 0.5)
                        projects[projectName]![groupName]![i].duration = 0.5
                    } else {
                        extraDurationUsed += extraDurationPerReport > 0 ? extraDurationPerReport : -extraDurationPerReport
                        projects[projectName]![groupName]![i].duration += extraDurationPerReport
                    }
                }
            }
        }
        let extraDurationUnused: Decimal = (extraDuration > 0 ? extraDuration : -extraDuration) - extraDurationUsed
        for (projectName, groups) in projects {
            for (groupName, reports) in groups {
                for i in 0..<reports.count {
                    projects[projectName]![groupName]![i].duration += extraDurationUnused
                    return projects
                }
            }
        }

        return projects
    }

    func saveReport (data: InvoiceData, pdfData: Data?, in project: Project, completion: @escaping (InvoiceFolder) -> Void) {

        repository.execute { baseUrl in
            // Generate folder if none exists
            let invoiceNr = "\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
            let invoiceFolderName = "\(data.date.yyyyMMdd)-\(invoiceNr)"

            let projectUrl = baseUrl.appendingPathComponent(project.name)
            let invoiceUrl = projectUrl.appendingPathComponent(invoiceFolderName)

            do {
                // Create folder if does not exist
                let write_folder = repository.writeFolder(at: invoiceUrl)

                // Save json
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let invoiceJsonUrl = invoiceUrl.appendingPathComponent("data.json")
                let jsonData = try encoder.encode(data)

                let write_json = repository.writeFile(jsonData, at: invoiceJsonUrl)

                let _ = Publishers.Zip(write_folder, write_json)
                .sink { x in
                    completion(InvoiceFolder(date: data.date, invoiceNr: invoiceNr, name: invoiceFolderName))
                }

                // Save pdf
                let pdfName = "Report-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
                let pdfUrl = invoiceUrl.appendingPathComponent(pdfName)
                try pdfData?.write(to: pdfUrl)
            }
            catch {
                print(error)
            }
        }
    }

}
