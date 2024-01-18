//
//  ReportState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine

class ReportInteractor {

    private let project: Project
    private let reportsInteractor: ReportsInteractor

    init (project: Project, reportsInteractor: ReportsInteractor) {
        print("init ReportInteractor")
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

        return reportsInteractor.readReportTemplates(in: project)
            .map { templates in
                // template_report
                // template_report_project
                // template_report_row

//                data.calculate()

                var template = data.toHtmlUsingTemplate(templates.0)
                let templateProject = templates.1
                let templateRow = templates.2

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
        return reportsInteractor.saveReport(data: data, pdfData: pdfData, in: project)
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
