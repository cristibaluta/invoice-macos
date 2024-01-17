//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import Combine
import SwiftCSV

class ReportEditorViewModel: ObservableObject, InvoiceEditorProtocol {

    let type: EditorType = .report
    var data: InvoiceData {
        didSet {
            invoiceDataSubject.send(data)
        }
    }

    @Published var allProjects: [ReportProject] = []
    @Published var reports: [Report] = []
    private var allReports: [Report] = []

    /// Publisher for data change
    var invoiceDataChangePublisher: AnyPublisher<InvoiceData, Never> { invoiceDataSubject.eraseToAnyPublisher() }
    private let invoiceDataSubject = PassthroughSubject<InvoiceData, Never>()
    /// Publisher for creating a new company
    var addCompanyPublisher: AnyPublisher<Void, Never> { addCompanySubject.eraseToAnyPublisher() }
    let addCompanySubject = PassthroughSubject<Void, Never>()

    init (data: InvoiceData) {
        self.data = data
        allReports = data.reports.map({
            Report(project_name: $0.project_name,
                   group: $0.group,
                   description: $0.description,
                   duration: $0.duration)
        })
        allProjects = projects(from: allReports, isOn: true)
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
//        calculate { _ in }
    }

    func updateReports() {
        self.reports = allReports.filter({
            let pn = $0.project_name
            return self.allProjects.contains(where: {$0.name == pn && $0.isOn})
        })
//        calculate { _ in }
    }
}

struct ReportEditor: View {
    
    @ObservedObject var viewModel: ReportEditorViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]
    
    init (viewModel: ReportEditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<viewModel.allProjects.count, id: \.self) { i in
                        Toggle(viewModel.allProjects[i].name, isOn: $viewModel.allProjects[i].isOn)
                        .onChange(of: viewModel.allProjects[i].isOn) { val in
                            viewModel.updateReports()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 50)
            .padding(10)

            Divider()
            List(viewModel.reports) { report in
                ReportRowView(report: report) { newReport in
                    viewModel.updateReport(newReport)
                }
            }
        }

    }

}
