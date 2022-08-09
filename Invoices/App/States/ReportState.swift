//
//  ReportState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine
import SwiftCSV

class ReportState: ObservableObject {

    @Published var isShowingEditorSheet = false
    @Published var html: String = ""
    @Published var allProjects: [ReportProject] = []
    @Published var reports: [Report] = []
    private var allReports: [Report] = []

    private var cancellable: Cancellable?
    private let reportsInteractor: ReportsInteractor

    var project: Project
    var printData: Data?
    var data: InvoiceData


    init (project: Project,
          data: InvoiceData,
          reportsInteractor: ReportsInteractor) {

        print("init ReportState")
        self.project = project
        self.data = data
        self.reportsInteractor = reportsInteractor

        self.allReports = data.reports.map({
            return Report(project_name: $0.project_name,
                          group: $0.group,
                          description: $0.description,
                          duration: $0.duration)
        })
        self.allProjects = projects(from: self.allReports, isOn: true)
    }

    func dismissEditor() {
        self.isShowingEditorSheet = false
    }

    func calculate (completion: @escaping (String) -> Void) {

        cancellable = reportsInteractor.readReportTemplates(in: project)
        .sink { templates in

            self.data.calculate()

            var template = self.data.toHtmlUsingTemplate(templates.0)
            let templateProject = templates.1
            let templateRow = templates.2

            // Calculate the total amount of units
            let units = self.data.products.reduce(0.0) { u, product in
                return u + product.units
            }
            template = template.replacingOccurrences(of: "::units::", with: units.stringValue_grouped2)

            let projects = self.reportsInteractor.groupReports(self.reports, duration: units)

            /// Add rows
            var projectsHtml = ""
            // Iterate over projects
            for (projectName, groups) in projects {
                guard self.allProjects.first(where: {$0.name == projectName})?.isOn == true else {
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
            template = template.replacingOccurrences(of: "::month::", with: self.data.date.fullMonthName)
            template = template.replacingOccurrences(of: "::year::", with: "\(self.data.date.year)")

            self.html = template
            completion(template)
        }
    }

    func save (pdfData: Data?, completion: @escaping (InvoiceFolder?) -> Void) {
        reportsInteractor.saveReport(data: data, pdfData: pdfData, in: project) { invoiceFolder in
            completion(invoiceFolder)
        }
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
                                    group: "",
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

            self.allProjects = projects(from: allReports, isOn: true)
            updateReports()
//            self.showingPopover = true
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
        for i in 0..<allReports.count {
            if allReports[i].id == report.id {
                allReports[i] = report
                break
            }
        }
        calculate { _ in }
    }

    func updateReports() {
        self.reports = allReports.filter({
            let pn = $0.project_name
            return self.allProjects.contains(where: {$0.name == pn && $0.isOn})
        })
        calculate { _ in }
    }

}
