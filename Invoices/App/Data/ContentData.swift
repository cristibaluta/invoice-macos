//
//  SelectedInvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

enum ContentType: Int {
    case invoice
    case report
}

// The content state is the source of truth for the invoice and the report
class ContentData: ObservableObject {

    @Published var contentType: ContentType = .invoice
    @Published var isShowingEditorSheet = false
    @Published var html: String = "" {
        didSet {
            self.htmlSubject.send(html)
        }
    }
    var htmlPublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    private let htmlSubject = PassthroughSubject<String, Never>()

    private var invoiceInteractor: InvoiceInteractor
    private var reportInteractor: ReportInteractor
    var invoiceEditorState: InvoiceEditorState
    var reportEditorState: ReportEditorState

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

        invoiceInteractor = InvoiceInteractor(project: project, invoicesInteractor: invoicesInteractor)
        reportInteractor = ReportInteractor(project: project, data: data, reportsInteractor: reportsInteractor)
        invoiceEditorState = InvoiceEditorState(data: data)
        reportEditorState = ReportEditorState(data: data)

        invoiceEditorState.invoiceDataPublisher
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)

        invoiceEditorState.addCompanyPublisher
            .sink { _ in
                print("Request to add new company")
            }
            .store(in: &cancellables)
    }

    func dismissEditor() {
        self.isShowingEditorSheet = false
    }

    func calculate() {
        switch contentType {
            case .invoice:
                _ = invoiceInteractor.calculate(data: data)
                    .sink { html in
                        self.html = html
                    }
            case .report:
                reportInteractor.calculate(reports: reportEditorState.reports, projects: reportEditorState.allProjects) { val in
                    self.html = val
                }
        }
    }

    func save() {
        switch contentType {
            case .invoice:
                invoiceInteractor.save(data: data, pdfData: pdfData)
                    .sink { invoiceFolder in

                    }
            case .report:
                reportInteractor.save(pdfData: pdfData) { invoiceFolder in

                }
        }
    }

    func export (isPdf: Bool) {
        var fileName = ""
        switch contentType {
            case .invoice:
                fileName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
            case .report:
                fileName = "Report-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
        }
        let exporter = Exporter()
        exporter.export(fileName: fileName,
                        data: data,
                        printData: pdfData,
                        html: html,
                        isPdf: isPdf)
    }

}
