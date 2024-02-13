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

    let id = UUID()// Needed to redraw the HtmlViewer
    @Published var editorType: EditorType = .invoice {
        didSet {
            buildHtml()
        }
    }
    @Published var isShowingEditorSheet = false
    @Published var hasChanges = false
    @Published var isEditing = false
    @Published var html: String = "Loading invoice..." {
        didSet {
            self.htmlSubject.send(html)
        }
    }
    var wrappedPdfData = WrappedData()

    private let htmlSubject = PassthroughSubject<String, Never>()
    var htmlDidChangePublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    var htmlCancellable: Cancellable?

    private let dataSaveSubject = PassthroughSubject<Invoice, Never>()
    var dataSavePublisher: AnyPublisher<Invoice, Never> { dataSaveSubject.eraseToAnyPublisher() }

    private let dataChangeSubject = PassthroughSubject<InvoiceData, Never>()
    var dataChangePublisher: AnyPublisher<InvoiceData, Never> { dataChangeSubject.eraseToAnyPublisher() }

    private var invoiceInteractor: InvoiceInteractor
    private var reportInteractor: ReportInteractor

    private var cancellables = Set<AnyCancellable>()
    private var activeEditorViewModel: (any InvoiceEditorProtocol)?

    var invoiceEditorViewModel: InvoiceEditorViewModel {
        if let viewModel = activeEditorViewModel as? InvoiceEditorViewModel {
            return viewModel
        }
        let viewModel = InvoiceEditorViewModel(data: data)
        viewModel.$data
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)
        viewModel.addCompanyPublisher
            .sink { _ in
                print("Request to add new company")
            }
            .store(in: &cancellables)
        activeEditorViewModel = viewModel
        isEditing = true
        return viewModel
    }

    var reportEditorViewModel: ReportEditorViewModel {
        if let viewModel = activeEditorViewModel as? ReportEditorViewModel {
            return viewModel
        }
        let viewModel = ReportEditorViewModel(data: data, reportInteractor: reportInteractor)
        viewModel.$data
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)
        activeEditorViewModel = viewModel
        isEditing = true
        return viewModel
    }

    private var project: Project
    private var data: InvoiceData {
        didSet {
            hasChanges = data != initialData
            buildHtml()
            dataChangeSubject.send(data)
        }
    }
    private let initialData: InvoiceData

    init (project: Project,
          data: InvoiceData,
          invoicesInteractor: InvoicesInteractor,
          reportsInteractor: ReportsInteractor) {

        self.project = project
        self.data = data
        self.initialData = data

        invoiceInteractor = InvoiceInteractor(repository: invoicesInteractor.repository, project: project)
        reportInteractor = ReportInteractor(repository: reportsInteractor.repository, project: project, reportsInteractor: reportsInteractor)

        buildHtml()
    }

    deinit {
        print(">>>>>>>> deinit InvoiceStore")
        cancellables.removeAll()
    }

    func dismissEditor() {
        isShowingEditorSheet = false
        isEditing = false
        activeEditorViewModel = nil
        cancellables.removeAll()
    }

    private func buildHtml() {
        switch editorType {
            case .invoice:
                _ = invoiceInteractor.buildHtml(data: data)
                    .sink { html in
                        self.html = html
                    }
            case .report:
                _ = reportInteractor.buildHtml(data: data)
                    .sink { html in
                        self.html = html
                    }
        }
    }

    func save() {
        switch editorType {
            case .invoice:
                _ = invoiceInteractor.save(data: data, pdfData: wrappedPdfData.data)
                    .sink { invoice in
                        self.hasChanges = false
                        self.dataSaveSubject.send(invoice)
                    }
            case .report:
                _ = reportInteractor.save(data: data, pdfData: wrappedPdfData.data)
                    .sink { invoice in
                        self.hasChanges = false
                        self.dataSaveSubject.send(invoice)
                    }
        }
    }

//    func export (isPdf: Bool) {
//        let fileName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
//        let exporter = Exporter()
//        exporter.export(fileName: fileName,
//                        data: data,
//                        printData: pdfData,
//                        html: html,
//                        isPdf: isPdf)
//    }

}
