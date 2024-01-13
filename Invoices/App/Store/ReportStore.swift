//
//  ReportStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 12.01.2024.
//

import Foundation
import Combine

// The content state is the source of truth for the invoice and the report
class ReportStore: ObservableObject {

    @Published var isShowingEditorSheet = false
    @Published var html: String = "" {
        didSet {
            self.htmlSubject.send(html)
        }
    }
    var htmlPublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    private let htmlSubject = PassthroughSubject<String, Never>()

    private var reportInteractor: ReportInteractor
    var reportEditorState: ReportEditorViewModel

    private var cancellable: Cancellable?
    private var cancellables = Set<AnyCancellable>()

    var project: Project
    var pdfData: Data?
    var data: InvoiceData {
        didSet {
            calculate()
        }
    }

    init (project: Project,
          data: InvoiceData,
          invoicesInteractor: InvoicesInteractor,
          reportsInteractor: ReportsInteractor) {

        self.project = project
        self.data = data

        reportInteractor = ReportInteractor(project: project, data: data, reportsInteractor: reportsInteractor)
        reportEditorState = ReportEditorViewModel(data: data)
    }

    func dismissEditor() {
        self.isShowingEditorSheet = false
    }

    func calculate() {
        reportInteractor.calculate(reports: reportEditorState.reports, projects: reportEditorState.allProjects) { val in
            self.html = val
        }
    }

    func save() {
        reportInteractor.save(pdfData: pdfData) { invoiceFolder in

        }
    }

    func export (isPdf: Bool) {
        let fileName = "Report-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
        let exporter = Exporter()
        exporter.export(fileName: fileName,
                        data: data,
                        printData: pdfData,
                        html: html,
                        isPdf: isPdf)
    }

}
