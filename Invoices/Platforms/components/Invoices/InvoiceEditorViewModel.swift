//
//  InvoiceEditorViewModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import Combine

class InvoiceEditorViewModel: ObservableObject, InvoiceEditorProtocol {

    var data: InvoiceData {
        didSet {
            invoiceDataSubject.send(data)
        }
    }

    @Published var invoiceSeries: String
    @Published var invoiceNr: String
    @Published var invoiceDate: Date
    @Published var invoicedDate: Date
    @Published var products: [InvoiceProductEditorViewModel]
    @Published var vat: String
    @Published var amountTotalVat: String
    @Published var clientName: String
    @Published var contractorName: String

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
        
        products = data.products.map({ InvoiceProductEditorViewModel(data: $0) })

        vat = data.vat.stringValue_2
        amountTotalVat = data.amount_total_vat.stringValue_2

        clientViewModel = CompanyViewViewModel(data: data.client)
        contractorViewModel = CompanyViewViewModel(data: data.contractor)
        clientName = data.client.name
        contractorName = data.contractor.name
    }

    deinit {
        print("<<<<<<< deinit InvoiceEditorViewModel")
    }

    func addNewProduct() {
        data.products.append(InvoiceProduct(product_name: "",
                                            rate: 0,
                                            exchange_rate: 0,
                                            units: 0,
                                            units_name: "",
                                            amount_per_unit: 0,
                                            amount: 0))
        products = data.products.map({ InvoiceProductEditorViewModel(data: $0) })
    }
}

class InvoiceProductEditorViewModel: ObservableObject, Identifiable {

    let id = UUID()
    var data: InvoiceProduct {
        didSet {
//            invoiceDataSubject.send(data)
        }
    }

    @Published var productName: String
    @Published var rate: String
    @Published var exchangeRate: String
    @Published var unitsName: String
    @Published var units: String
    @Published var amount: String

    init (data: InvoiceProduct) {

        self.data = data

        productName = data.product_name
        rate = data.rate.stringValue_2
        exchangeRate = data.exchange_rate.stringValue_4
        unitsName = data.units_name
        units = data.units.stringValue
        amount = data.amount.stringValue_2
    }
}
