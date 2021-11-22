//
//  ReportStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import SwiftCSV

struct Report: Identifiable {
    var id = UUID()
    var project_name: String
    var group: String?
    var description: String
    var duration: Decimal
}

class ReportStore: ObservableObject {
    
    var printingData: Data?
    var data: InvoiceData
    @Published var reports: [Report] = []
    @Published var html: String
    
    init (data: InvoiceData) {
        self.html = ""
        self.data = data
        self.reports = data.reports.map({
            return Report(project_name: $0.project_name,
                          group: $0.group,
                          description: $0.description,
                          duration: $0.duration)
        })
        calculate()
    }
    
    func openCsv (at fileUrl: URL) {
        do {
            let csv = try CSV(url: fileUrl, delimiter: ";")
            var reports = [Report]()
            try csv.enumerateAsDict { dict in
                let report = Report(project_name: dict["Project Name"] ?? "",
                                    group: nil,
                                    description: dict["Work Description"] ?? "",
                                    duration: Decimal(Double(dict["Hours"]?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0))
                
                // Find duplicate and add time
                var foundDuplicate = false
                for i in 0..<reports.count {
                    if reports[i].description == report.description {
                        reports[i].duration += report.duration
                        foundDuplicate = true
                        break
                    }
                }
                if !foundDuplicate {
                    reports.append(report)
                }
            }
            self.reports = reports
            calculate()
        } catch {
            print(error)
        }
    }
    
    func updateReport (_ report: Report) {
        for i in 0..<reports.count {
            if reports[i].id == report.id {
                reports[i] = report
                break
            }
        }
        calculate()
    }
    
    func calculate() {
        SandboxManager.executeInSelectedDir { url in
            /// Get template
            let templateUrl = url.appendingPathComponent("templates")
            let reportUrl = templateUrl.appendingPathComponent("template_report.html")
            let projectUrl = templateUrl.appendingPathComponent("template_report_project.html")
            let rowUrl = templateUrl.appendingPathComponent("template_report_row.html")
            
            guard var template = try? String(contentsOfFile: reportUrl.path),
                  let templateProject = try? String(contentsOfFile: projectUrl.path),
                  let templateRow = try? String(contentsOfFile: rowUrl.path) else {
                  html = "Error: Templates are missing!"
                return
            }
            
            template = data.toHtmlUsingTemplate(template)
            
            // Calculate total amount of units
            let units = data.products.reduce(0.0) { u, product in
                return u + product.units
            }
            template = template.replacingOccurrences(of: "::units::", with: units.stringValue_grouped2)
            
            // Group reports by projects then by groups
            var projects = [String: [String: [Report]]]()
            for report in reports {
                var groups = projects[report.project_name] ?? [:]
                var groupReports = groups[report.group ?? ""] ?? []
                groupReports.append(report)
                groups[report.group ?? ""] = groupReports
                projects[report.project_name] = groups
            }
            
            /// Add rows
            var projectsHtml = ""
            for (projectName, groups) in projects {
                var project = templateProject.replacingOccurrences(of: "::project_name::", with: projectName)
                var rowsHtml = ""
                
                // Iterate over groups
                for (groupName, reports) in groups {
                    guard groupName != "" else {
                        // No group, add each report as a new table row
                        for report in reports {
                            var row = templateRow
                            row = row.replacingOccurrences(of: "::task::", with: report.description)
                            row = row.replacingOccurrences(of: "::duration::",
                                                           with: report.duration.stringValue_grouped2)
                            rowsHtml += row
                        }
                        continue
                    }
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
                    row = row.replacingOccurrences(of: "::duration::",
                                                             with: duration.stringValue_grouped2)
                    rowsHtml += row
                }
                
                project = project.replacingOccurrences(of: "::rows::", with: rowsHtml)
                projectsHtml += project
            }
            
            template = template.replacingOccurrences(of: "::projects::", with: projectsHtml)
            template = template.replacingOccurrences(of: "::month::", with: data.date.fullMonthName)
            template = template.replacingOccurrences(of: "::year::", with: "\(data.date.year)")
            
            self.html = template
        }
    }
    
    func save() {
        SandboxManager.executeInSelectedDir { url in
            do {
                // Generate folder if none exists
                let folderName = "\(data.date.yyyyMMdd)-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
                let invoiceUrl = url.appendingPathComponent(folderName)
                try FileManager.default.createDirectory(at: invoiceUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                // Add reports to json
                let reports: [InvoiceReport] = self.reports.map({
                    return InvoiceReport(project_name: $0.project_name,
                                         group: $0.group,
                                         description: $0.description,
                                         duration: $0.duration)
                })
                data.reports = reports
                // Save json
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let invoiceJsonUrl = invoiceUrl.appendingPathComponent("data.json")
                let jsonData = try encoder.encode(data)
                try jsonData.write(to: invoiceJsonUrl)
                
                // Save report pdf
                let pdfName = "Report-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
                let reportPdfUrl = invoiceUrl.appendingPathComponent(pdfName)
                try printingData?.write(to: reportPdfUrl)
            }
            catch {
                print(error)
            }
        }
    }
}
