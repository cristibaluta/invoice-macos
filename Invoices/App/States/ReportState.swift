//
//  ReportState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine

class ReportState: ObservableObject {

//    @Published var isShowingEditorSheet = false

    private var cancellable: Cancellable?
    private let reportsInteractor: ReportsInteractor

    var folder: Folder
    var data: InvoiceData
    var printData: Data?
    var html = ""


    init (folder: Folder,
          data: InvoiceData,
          reportsInteractor: ReportsInteractor) {

        print("init ReportState")
        self.folder = folder
        self.data = data
        self.reportsInteractor = reportsInteractor
    }

//    func dismissEditor() {
//        self.isShowingEditorSheet = false
//    }

    func calculate (reports: [Report], projects allProjects: [Project], completion: @escaping (String) -> Void) {

        cancellable = reportsInteractor.readReportTemplates(in: folder)
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
            template = template.replacingOccurrences(of: "::month::", with: self.data.date.fullMonthName)
            template = template.replacingOccurrences(of: "::year::", with: "\(self.data.date.year)")

            self.html = template
            completion(self.html)
        }
    }

    func save (pdfData: Data?, completion: @escaping (Invoice?) -> Void) {
        reportsInteractor.saveReport(data: data, pdfData: pdfData, in: folder) { invoice in
            completion(invoice)
        }
    }

}
