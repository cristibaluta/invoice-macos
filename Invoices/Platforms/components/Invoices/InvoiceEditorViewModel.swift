//
//  InvoiceEditorViewModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import Combine

class InvoiceEditorViewModel: ObservableObject, InvoiceEditorProtocol {

    let type: EditorType = .invoice
    var data: InvoiceData {
        didSet {
            invoiceDataSubject.send(data)
        }
    }

    @Published var invoiceSeries: String
    @Published var invoiceNr: String
    @Published var invoiceDate: Date
    @Published var invoicedDate: Date
    @Published var rate: String
    @Published var exchangeRate: String
    @Published var units: String
    @Published var unitsName: String
    @Published var productName: String
    @Published var vat: String
    @Published var amountTotalVat: String
    @Published var isFixedTotal: Bool = false
    @Published var clientName: String = "Add new"
    @Published var contractorName: String = "Add new"

    private var clientViewModel: CompanyViewViewModel
    private var contractorViewModel: CompanyViewViewModel

    /// Publisher for data change
    var invoiceDataChangePublisher: AnyPublisher<InvoiceData, Never> { invoiceDataSubject.eraseToAnyPublisher() }
    private let invoiceDataSubject = PassthroughSubject<InvoiceData, Never>()
    /// Publisher to add new company
    var addCompanyPublisher: AnyPublisher<Void, Never> { addCompanySubject.eraseToAnyPublisher() }
    let addCompanySubject = PassthroughSubject<Void, Never>()


    init (data: InvoiceData) {
        print(">>>>>>>> init InvoiceEditorViewModel")
        self.data = data

        invoiceSeries = data.invoice_series
        invoiceNr = String(data.invoice_nr)
        invoiceDate = Date(yyyyMMdd: data.invoice_date) ?? Date()
        invoicedDate = Date(yyyyMMdd: data.invoiced_period) ?? Date()
        vat = data.vat.stringValue_2
        amountTotalVat = data.amount_total_vat.stringValue_2

        rate = data.products[0].rate.stringValue_2
        exchangeRate = data.products[0].exchange_rate.stringValue_4
        units = data.products[0].units.stringValue
        unitsName = data.products[0].units_name
        productName = data.products[0].product_name

        clientViewModel = CompanyViewViewModel(data: data.client)
        contractorViewModel = CompanyViewViewModel(data: data.contractor)
        clientName = data.client.name
        contractorName = data.contractor.name
    }

    deinit {
        print("<<<<<<< deinit InvoiceEditorViewModel")
    }
}
