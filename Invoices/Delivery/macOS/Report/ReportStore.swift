//
//  ReportStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import SwiftCSV

class ReportStore: ObservableObject {
    
    var printingData: Data?
    var data: InvoiceData
    @Published var showingPopover = false
    @Published var allProjects: [ReportProject] = []
    @Published var reports: [Report] = []
    private var allReports: [Report] = []
    @Published var html: String
    
    init (data: InvoiceData) {
        self.html = ""
        self.data = data
        self.allReports = data.reports.map({
            return Report(project_name: $0.project_name,
                          group: $0.group,
                          description: $0.description,
                          duration: $0.duration)
        })
        self.allProjects = projects(from: reports, isOn: true)
        self.reports = allReports.filter({
            let pn = $0.project_name
            return self.allProjects.contains(where: {$0.name == pn && $0.isOn})
        })
        calculate()
    }
    
    func reloadData() {
        
    }
    
    func openCsv (at fileUrl: URL) {
        do {
            let csv = try CSV(url: fileUrl, delimiter: ";")
            allReports = [Report]()
            try csv.enumerateAsDict { dict in
                guard let projectName = dict["Project Name"], !projectName.isEmpty else {
                    return
                }
                let report = Report(project_name: projectName,
                                    group: nil,
                                    description: dict["Work Description"] ?? "",
                                    duration: Decimal(Double(dict["Hours"]?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0))
                
                // Find duplicate and add times together
                var foundDuplicate = false
                for i in 0..<self.allReports.count {
                    if self.allReports[i].description == report.description {
                        self.allReports[i].duration += report.duration
                        foundDuplicate = true
                        break
                    }
                }
                if !foundDuplicate {
                    self.allReports.append(report)
                }
            }
            
            self.allProjects = projects(from: allReports, isOn: false)
            self.showingPopover = true
            calculate()
        } catch {
            print(error)
        }
    }
    
    private func projects (from reports: [Report], isOn: Bool) -> [ReportProject] {
        var arr = [ReportProject]()
        for report in reports {
            if !arr.contains(where: {$0.name == report.project_name}) {
                arr.append(ReportProject(name: report.project_name, isOn: isOn))
            }
        }
        return arr
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
    
    func updateReports() {
        self.reports = allReports.filter({
            let pn = $0.project_name
            return self.allProjects.contains(where: {$0.name == pn && $0.isOn})
        })
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
            
            let projects = ReportsInteractor().groupReports(reports, duration: units)
            
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
