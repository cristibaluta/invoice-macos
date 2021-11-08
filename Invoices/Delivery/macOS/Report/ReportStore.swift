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
    var duration: Double
}

class ReportStore: ObservableObject {
    
    var printingData: Data?
    var data: InvoiceData
    var invoiceDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(data) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    @Published var reports: [Report] = []
    @Published var html: String
    
    private var projects = [String: [Report]]()
    
    
    init (data: InvoiceData) {
        self.html = ""
        self.data = data
        calculate()
    }
    
    func openCsv (at fileUrl: URL) {
        do {
            let csv = try CSV(url: fileUrl, delimiter: ";")
            projects = [:]
            var reports = [Report]()
            try csv.enumerateAsDict { dict in
                let report = Report(project_name: dict["Project Name"] ?? "",
                                    group: nil,
                                    description: dict["Work Description"] ?? "",
                                    duration: Double(dict["Hours"]?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0)
                reports.append(report)
                var projectReports = self.projects[report.project_name] ?? []
                // Find duplicate
                var foundDuplicate = false
                for i in 0..<projectReports.count {
                    if projectReports[i].description == report.description {
                        projectReports[i].duration += report.duration
                        foundDuplicate = true
                        break
                    }
                }
                if !foundDuplicate {
                    projectReports.append(report)
                }
                self.projects[report.project_name] = projectReports
            }
            self.reports = reports
            calculate()
        } catch {
            print(error)
        }
    }
    
    func deleteReport (_ report: Report) {
        
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
            
            /// Add new invoice data to the template
            /// Convert the data to dictionary
            for (key, value) in (invoiceDictionary ?? [:]) {
                if key == "invoice_date", let date = Date(yyyyMMdd: value as? String ?? "") {
                    template = template.replacingOccurrences(of: "::\(key)::", with: "\(date.ddMMMyyyy)")
                }
                else if key == "contractor", let dic = value as? [String: Any] {
                    for (k, v) in dic {
                        template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                    }
                } else if key == "client", let dic = value as? [String: Any] {
                    for (k, v) in dic {
                        template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                    }
                } else {
                    template = template.replacingOccurrences(of: "::\(key)::", with: "\(value)")
                }
            }
            // Calculate total units
            let units = data.products.reduce(0.0) { u, product in
                return u + product.units
            }
            template = template.replacingOccurrences(of: "::units::", with: units.stringFormatWith2Digits)
            
            /// Add rows
            var projectsHtml = ""
            for (projectName, reports) in projects {
                var project = templateProject.replacingOccurrences(of: "::project_name::", with: projectName)
                
                var rowsHtml = ""
                for report in reports {
                    var row = templateRow
                    row = row.replacingOccurrences(of: "::task::", with: report.description)
                    row = row.replacingOccurrences(of: "::duration::",
                                                   with: report.duration.stringFormatWith2Digits)
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
                let invoiceUrl = url.appendingPathComponent(data.date.yyyyMMdd)
                try FileManager.default.createDirectory(at: invoiceUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                // Add reports to json
                
                // Save json
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let invoiceJsonUrl = invoiceUrl.appendingPathComponent("data.json")
                let jsonData = try encoder.encode(data)
                try jsonData.write(to: invoiceJsonUrl)
                
                // Save report pdf
                let reportPdfUrl = invoiceUrl.appendingPathComponent("report-\(data.invoice_series)\(data.invoice_nr)-\(data.date.yyyyMMdd).pdf")
                try printingData?.write(to: reportPdfUrl)
            }
            catch {
                print(error)
            }
        }
    }
}
