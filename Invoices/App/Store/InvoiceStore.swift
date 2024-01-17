//
//  SelectedInvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

// Source of truth for the invoice data
// It also stores the html to display
class InvoiceStore: ObservableObject {

    @Published var isShowingEditorSheet = false
    @Published var html: String = "Loading invoice..."
    {
        didSet {
            self.htmlSubject.send(html)
        }
    }
    var htmlDidChangePublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    private let htmlSubject = PassthroughSubject<String, Never>()

    private var invoiceInteractor: InvoiceInteractor
    private var reportInteractor: ReportInteractor

    private var cancellables = Set<AnyCancellable>()
    private var editorViewModel: (any InvoiceEditorProtocol)?

    var id = UUID()// Needed to redraw the HtmlViewer
    var project: Project
    var pdfData: Data?
    var data: InvoiceData {
        didSet {
            calculate(editorType: .invoice)
        }
    }

    init (project: Project,
          data: InvoiceData,
          invoicesInteractor: InvoicesInteractor,
          reportsInteractor: ReportsInteractor) {

        self.project = project
        self.data = data

        invoiceInteractor = InvoiceInteractor(project: project, invoicesInteractor: invoicesInteractor)
        reportInteractor = ReportInteractor(project: project, reportsInteractor: reportsInteractor)
    }

    deinit {
        print(">>>>>>>> deinit InvoiceStore")
    }

    func createInvoiceEditor() -> InvoiceEditorViewModel {
        if let viewModel = editorViewModel as? InvoiceEditorViewModel {
            return viewModel
        }
        print(">>>>>>>> create InvoiceEditorViewModel")
        let viewModel = InvoiceEditorViewModel(data: data)
        viewModel.invoiceDataChangePublisher
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)
        viewModel.addCompanyPublisher
            .sink { _ in
                print("Request to add new company")
            }
            .store(in: &cancellables)
        self.editorViewModel = viewModel
        return viewModel
    }

    func createReportEditor() -> ReportEditorViewModel {
        let viewModel = ReportEditorViewModel(data: data)
        viewModel.invoiceDataChangePublisher
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)
        return viewModel
    }

    func dismissEditor() {
        isShowingEditorSheet = false
        editorViewModel = nil
        cancellables.removeAll()
    }

    func calculate(editorType: EditorType) {
        switch editorType {
            case .invoice:
                _ = invoiceInteractor.calculate(data: data)
                    .sink { html in
                        self.html = html
                    }
            case .report:
                _ = reportInteractor.calculate(data: data, reports: [], projects: [])
                    .sink { html in
                        self.html = html
                    }
        }
    }

    func save() {
        _ = invoiceInteractor.save(data: data, pdfData: pdfData)
            .sink { invoiceFolder in

            }
    }

    func export (isPdf: Bool) {
//        let fileName = "Report-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
        let fileName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
        let exporter = Exporter()
        exporter.export(fileName: fileName,
                        data: data,
                        printData: pdfData,
                        html: html,
                        isPdf: isPdf)
    }

}
