//
//  ReportEditorViewModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import Combine

class ReportEditorModel: ObservableObject, InvoiceEditorProtocol {

    @Published var data: InvoiceData
    private let reportInteractor: ReportInteractor

    @Published var allProjects: [ReportProject] = []
    @Published var reports: [Report] = []
    private var allReports: [Report] = []

    /// Publisher for creating a new company. Unused in reports
    var addCompanyPublisher = PassthroughSubject<Void, Never>().eraseToAnyPublisher()


    init (data: InvoiceData, reportInteractor: ReportInteractor) {
        print(">>>>>>> init ReportEditorViewModel")
        self.data = data
        self.reportInteractor = reportInteractor

        allReports = data.reports.map({
            Report(project_name: $0.project_name,
                   group: $0.group,
                   description: $0.description,
                   duration: $0.duration)
        })
        allProjects = projects(from: allReports, isOn: true)
        updateReports()
    }

    deinit {
        print("<<<<<<< deinit ReportEditorViewModel")
    }

    func importCsv (at fileUrl: URL) {
        let report = reportInteractor.readCsv(at: fileUrl)
        allReports = report.0
        allProjects = report.1
        data.reports = allReports.map {
            InvoiceReport(project_name: $0.project_name, 
                          group: $0.group,
                          description: $0.description,
                          duration: $0.duration)
        }
        updateReports()
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
        updateData()
    }

    func updateReports() {
        reports = allReports.filter({
            let pn = $0.project_name
            return allProjects.contains(where: {
                $0.name == pn && $0.isOn
            })
        })
    }

    private func updateData() {
        data.reports = allReports.map {
            InvoiceReport(project_name: $0.project_name,
                          group: $0.group,
                          description: $0.description,
                          duration: $0.duration)
        }
    }
}
