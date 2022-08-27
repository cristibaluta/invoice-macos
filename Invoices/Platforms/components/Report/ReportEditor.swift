//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import Combine
import SwiftCSV

class ReportEditorState: ObservableObject {

    var data: InvoiceData {
        didSet {
            invoiceDataSubject.send(data)
        }
    }

    @Published var allProjects: [ReportProject] = []
    @Published var reports: [Report] = []
    private var allReports: [Report] = []

    /// Publisher for data change
    var invoiceDataPublisher: AnyPublisher<InvoiceData, Never> { invoiceDataSubject.eraseToAnyPublisher() }
    private let invoiceDataSubject = PassthroughSubject<InvoiceData, Never>()

    init (data: InvoiceData) {
        print("init InvoiceEditorState")
        self.data = data
        self.allReports = data.reports.map({
            return Report(project_name: $0.project_name,
                          group: $0.group,
                          description: $0.description,
                          duration: $0.duration)
        })
        self.allProjects = projects(from: self.allReports, isOn: true)
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
    
    @ObservedObject var state: ReportEditorState
    
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]
    
    init (state: ReportEditorState) {
        self.state = state
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<state.allProjects.count) { i in
                        Toggle(state.allProjects[i].name, isOn: $state.allProjects[i].isOn)
                        .onChange(of: state.allProjects[i].isOn) { val in
                            state.updateReports()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 50)
            .padding(10)

            Divider()
            List(self.state.reports) { report in
                ReportRowView(report: report) { newReport in
                    state.updateReport(newReport)
                }
            }
        }

    }

}
