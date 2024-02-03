//
//  InvoiceEditorViewModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import Combine

class InvoiceEditorViewModel: ObservableObject, InvoiceEditorProtocol {

    @Published var data: InvoiceData {
        didSet {
            print(">>>>>>>>. did change data")
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

    /// Publisher to add new company
    var addCompanyPublisher: AnyPublisher<Void, Never> { addCompanySubject.eraseToAnyPublisher() }
    let addCompanySubject = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()
    private var productsCancellables = Set<AnyCancellable>()


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
        clientName = data.client.name.isEmpty ? "-" : data.client.name
        contractorName = data.contractor.name.isEmpty ? "-" : data.contractor.name


        $invoiceSeries.removeDuplicates().sink { newValue in self.data.invoice_series = newValue }
        .store(in: &cancellables)

        $invoiceNr.removeDuplicates().sink { newValue in self.data.invoice_nr = Int(newValue) ?? 0 }
        .store(in: &cancellables)

        $invoiceDate.removeDuplicates().sink { newValue in self.data.invoice_date = newValue.yyyyMMdd }
        .store(in: &cancellables)

        $invoicedDate.removeDuplicates().sink { newValue in self.data.invoiced_period = newValue.yyyyMMdd }
        .store(in: &cancellables)

        $vat.removeDuplicates().sink { newValue in
            self.data.vat = Decimal(string: newValue) ?? 0
            // When VAT changes recalculate the total amount
            self.data.calculate()
            self.amountTotalVat = self.data.amount_total_vat.stringValue_2
        }
        .store(in: &cancellables)

        subscribeToProductsChanges()
    }

    deinit {
        print("<<<<<<< deinit InvoiceEditorViewModel")
        cancellables.removeAll()
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
        subscribeToProductsChanges()
    }

    private func subscribeToProductsChanges() {
        productsCancellables.removeAll()

        for i in 0..<products.count {
            products[i].$data.sink { [weak self] newData in
                guard let self else {
                    return
                }
                self.data.products[i] = newData
                self.data.calculate()
                self.amountTotalVat = self.data.amount_total_vat.stringValue_2
            }
            .store(in: &productsCancellables)
        }
    }
}

class InvoiceProductEditorViewModel: ObservableObject, Identifiable {

    let id = UUID()
    @Published var data: InvoiceProduct

    @Published var productName: String
    @Published var rate: String
    @Published var exchangeRate: String
    @Published var unitsName: String
    @Published var units: String
    @Published var amount: String

    private var cancellables = Set<AnyCancellable>()

    init (data: InvoiceProduct) {

        self.data = data

        productName = data.product_name
        rate = data.rate.stringValue_2
        exchangeRate = data.exchange_rate.stringValue_4
        unitsName = data.units_name
        units = data.units.stringValue
        amount = data.amount.stringValue_2

        $productName.removeDuplicates().sink { newValue in
            self.data.product_name = newValue
        }
        .store(in: &cancellables)

        $rate.removeDuplicates().sink { newValue in
            print(">>>>>> rate.sink \(newValue)")
            self.data.rate = Decimal(string: newValue) ?? 0
            self.calculateAmount()
        }
        .store(in: &cancellables)

        $exchangeRate.removeDuplicates().sink { newValue in
            print(">>>>>> exchangerate.sink \(newValue)")
            self.data.exchange_rate = Decimal(string: newValue) ?? 0
            self.calculateAmount()
        }
        .store(in: &cancellables)

        //        .assign(to: \.units_name, on: self.data)
        $unitsName.removeDuplicates().sink { newValue in
            self.data.units_name = newValue
        }
        .store(in: &cancellables)

        $units.removeDuplicates().sink { newValue in
            print(">>>>>> units.sink \(newValue)")
            self.data.units = Decimal(string: newValue) ?? 0
            self.calculateAmount()
        }
        .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }

    private func calculateAmount() {
        data.calculate()
        amount = data.amount.stringValue_2
    }
}
