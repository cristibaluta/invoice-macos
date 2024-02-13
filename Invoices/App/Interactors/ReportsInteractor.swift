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

}
