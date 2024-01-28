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

    @Published var editorType: EditorType = .invoice
    @Published var isShowingEditorSheet = false
    @Published var hasChanges = false
    @Published var isEditing = false
    @Published var html: String = "Loading invoice..." {
        didSet {
            self.htmlSubject.send(html)
        }
    }
    private let htmlSubject = PassthroughSubject<String, Never>()
    var htmlDidChangePublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    var htmlCancellable: Cancellable?

    private var invoiceInteractor: InvoiceInteractor
    private var reportInteractor: ReportInteractor

    private var cancellables = Set<AnyCancellable>()
    private var activeEditorViewModel: (any InvoiceEditorProtocol)?

    var invoiceEditorViewModel: InvoiceEditorViewModel {
        if let viewModel = activeEditorViewModel as? InvoiceEditorViewModel {
            return viewModel
        }
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
        activeEditorViewModel = viewModel
        isEditing = true
        return viewModel
    }

    var reportEditorViewModel: ReportEditorViewModel {
        if let viewModel = activeEditorViewModel as? ReportEditorViewModel {
            return viewModel
        }
        let viewModel = ReportEditorViewModel(data: data, reportInteractor: reportInteractor)
        viewModel.invoiceDataChangePublisher
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)
        activeEditorViewModel = viewModel
        isEditing = true
        return viewModel
    }

    var id = UUID()// Needed to redraw the HtmlViewer
    private var project: Project
    var pdfData: Data?
    private var data: InvoiceData {
        didSet {
            hasChanges = data != initialData
            buildHtml()
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

        invoiceInteractor = InvoiceInteractor(project: project, invoicesInteractor: invoicesInteractor)
        reportInteractor = ReportInteractor(project: project, reportsInteractor: reportsInteractor)

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

    func buildHtml() {
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
                _ = invoiceInteractor.save(data: data, pdfData: pdfData)
                    .sink { invoiceFolder in

                    }
            case .report:
                _ = reportInteractor.save(data: data, pdfData: pdfData)
                    .sink { invoiceFolder in

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
