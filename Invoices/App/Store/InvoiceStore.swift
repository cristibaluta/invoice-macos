//
//  SelectedInvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

// Source of truth for the invoice
class InvoiceStore: ObservableObject {

    @Published var isShowingEditorSheet = false
    @Published var html: String = "Loading invoice..."
    {
        didSet {
//            self.objectWillChange.send()
            self.htmlSubject.send(html)
        }
    }
    var htmlDidChangePublisher: AnyPublisher<String, Never> { htmlSubject.eraseToAnyPublisher() }
    private let htmlSubject = PassthroughSubject<String, Never>()

    private var invoiceInteractor: InvoiceInteractor
    var invoiceEditorViewModel: InvoiceEditorViewModel
    var reportEditorViewModel: ReportEditorViewModel

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

        invoiceEditorViewModel = InvoiceEditorViewModel(data: data)
        reportEditorViewModel = ReportEditorViewModel(data: data)

        invoiceEditorViewModel.invoiceDataChangePublisher
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)
        reportEditorViewModel.invoiceDataChangePublisher
            .sink { newData in
                self.data = newData
            }
            .store(in: &cancellables)

        invoiceEditorViewModel.addCompanyPublisher
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
//        reportInteractor.calculate(reports: reportEditorState.reports, projects: reportEditorState.allProjects) { val in
//            self.html = val
//        }
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
