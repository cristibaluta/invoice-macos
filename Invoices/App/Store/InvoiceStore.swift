//
//  SelectedInvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

// The content state is the source of truth for the invoice and the report
class InvoiceStore: ObservableObject {

    @Published var isShowingEditorSheet = false
    @Published var html: String = "" {
        didSet {
            self.htmlSubject.send(html)
        }
    }
    var htmlPublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    private let htmlSubject = PassthroughSubject<String, Never>()

    private var invoiceInteractor: InvoiceInteractor
    var invoiceEditorState: InvoiceEditorViewModel

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
          invoicesInteractor: InvoicesInteractor) {

        self.project = project
        self.data = data

        invoiceInteractor = InvoiceInteractor(project: project, invoicesInteractor: invoicesInteractor)
        invoiceEditorState = InvoiceEditorViewModel(data: data)

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
        _ = invoiceInteractor.calculate(data: data)
            .sink { html in
                self.html = html
            }
    }

    func save() {
        _ = invoiceInteractor.save(data: data, pdfData: pdfData)
            .sink { invoiceFolder in

            }
    }

    func export (isPdf: Bool) {
        let fileName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
        let exporter = Exporter()
        exporter.export(fileName: fileName,
                        data: data,
                        printData: pdfData,
                        html: html,
                        isPdf: isPdf)
    }

}
