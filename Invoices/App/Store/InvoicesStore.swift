//
//  InvoicesState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

class InvoicesStore: ObservableObject {

    var id = UUID()// Needed to redraw the HtmlViewer
    @Published var invoices: [Invoice] = []
    @Published var selectedInvoice: Invoice?

    @Published var isShowingNewInvoiceSheet = false
    @Published var isShowingEditInvoiceSheet = false
    @Published var isShowingDeleteInvoiceAlert = false


    private var repository: Repository
    private var project: Project
    private var cancellables = Set<AnyCancellable>()
    private let invoicesInteractor: InvoicesInteractor
    private let reportsInteractor: ReportsInteractor
    var selectedInvoiceStore: InvoiceStore?

    private let chartSubject = PassthroughSubject<ChartsViewModel, Never>()
    var chartPublisher: AnyPublisher<ChartsViewModel, Never> {
        chartSubject.eraseToAnyPublisher()
    }
    var chartCancellable: Cancellable?

    private let newInvoiceSubject = PassthroughSubject<InvoiceStore, Never>()
    var newInvoicePublisher: AnyPublisher<InvoiceStore, Never> {
        newInvoiceSubject.eraseToAnyPublisher()
    }
    var newInvoiceCancellable: Cancellable?


    init (repository: Repository, project: Project) {
        
        self.repository = repository
        self.project = project

        invoicesInteractor = InvoicesInteractor(repository: repository)
        reportsInteractor = ReportsInteractor(repository: repository)
    }

    func loadInvoices() {
        _ = invoicesInteractor.refreshInvoicesList(for: project)
            .sink { [weak self] in
                print("Invoices loaded \($0.count)")
                self?.invoices = $0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    self?.loadChart()
                }
            }
    }

    func loadInvoice (_ invoice: Invoice) -> AnyPublisher<InvoiceStore, Never> {

        selectedInvoice = invoice

        return invoicesInteractor.readInvoice(for: invoice, in: project)
            .map { invoiceData in
                let invoiceStore = InvoiceStore(project: self.project,
                                                data: invoiceData,
                                                invoicesInteractor: self.invoicesInteractor,
                                                reportsInteractor: self.reportsInteractor)

                self.selectedInvoiceStore = invoiceStore
//                self.selectedInvoiceStore?.calculate()

                return invoiceStore
            }
            .eraseToAnyPublisher()
    }

    func createNextInvoiceInProject() {

        guard let lastInvoice = invoices.first else {
            // If this is the first invoice create an empty invoice
            let data = InvoicesInteractor.emptyInvoiceData
            let invoice = Invoice(date: data.date,
                                  invoiceNr: "\(data.invoice_series)\(data.invoice_nr)",
                                  name: "\(data.date.yyyyMMdd)-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)")
            self.invoices = [invoice]
            self.selectedInvoiceStore = InvoiceStore(project: project,
                                                     data: data,
                                                     invoicesInteractor: invoicesInteractor,
                                                     reportsInteractor: reportsInteractor)
            self.selectedInvoiceStore?.buildHtml()
            self.newInvoiceSubject.send(self.selectedInvoiceStore!)
            return
        }

        // Duplicate the last invoice
        _ = invoicesInteractor.readInvoice(for: lastInvoice, in: project)
        .sink {
            var data = $0
            /// Increase invoice nr
            data.invoice_nr += 1
            /// Set invoice date to last working day of the next month
            let nextDate = Date(yyyyMMdd: data.invoice_date)?.nextMonth().endOfMonth(lastWorkingDay: true) ?? Date()
            data.invoice_date = nextDate.yyyyMMdd
            /// Remove the old reports
            data.reports = []
            /// Create new invoice and insert it in the list
            let invoice = Invoice(date: nextDate,
                                  invoiceNr: "\(data.invoice_series)\(data.invoice_nr)",
                                  name: "\(nextDate.yyyyMMdd)-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)")
            self.invoices.insert(invoice, at: 0)
            /// Update the state
            self.selectedInvoiceStore = InvoiceStore(project: self.project,
                                                     data: data,
                                                     invoicesInteractor: self.invoicesInteractor,
                                                     reportsInteractor: self.reportsInteractor)
            self.selectedInvoiceStore?.buildHtml()
            self.newInvoiceSubject.send(self.selectedInvoiceStore!)
        }
    }

    func deleteInvoice (at index: Int) {
        guard index < invoices.count else {
            return
        }
        let invoice = invoices[index]
        _ = invoicesInteractor.deleteInvoice(invoice, in: project)
            .sink { success in
                self.invoices.remove(at: index)
                self.loadChart()
            }
    }

    func deleteInvoice (_ invoice: Invoice) {
        guard let index = invoices.firstIndex(of: invoice) else {
            fatalError("Index not found")
        }
        _ = invoicesInteractor.deleteInvoice(invoice, in: project)
            .sink { success in
                self.invoices.remove(at: index)
                self.loadChart()
            }
    }

    func dismissNewInvoice() {
        isShowingNewInvoiceSheet = false
    }

    func dismissInvoiceEditor() {
        isShowingEditInvoiceSheet = false
    }

    func dismissDeleteInvoice() {
        isShowingDeleteInvoiceAlert = false
    }

    func path (for invoice: Invoice) -> String {
        return repository.baseUrl
            .appendingPathComponent(project.name)
            .appendingPathComponent(invoice.name)
            .path
    }


    func loadChart() {
        guard !invoices.isEmpty else {
            chartSubject.send(ChartsViewModel(invoices: []))
            return
        }

        _ = invoicesInteractor.readInvoices(invoices, in: project)
            .sink { invoicesData in
                self.chartSubject.send(ChartsViewModel(invoices: invoicesData))
            }
    }

}

