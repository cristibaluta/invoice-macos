//
//  InvoiceEditorViewModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import Combine

class InvoiceEditorModel: ObservableObject, InvoiceEditorProtocol {

    @Published var data: InvoiceData {
        didSet {
            print(">>>>>>>>. did change data")
        }
    }

    @Published var invoiceSeries: String
    @Published var invoiceNr: String
    @Published var invoiceDate: Date
    @Published var invoicedDate: Date
    @Published var products: [ProductRowModel]
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
        
        products = data.products.map({ ProductRowModel(data: $0) })

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
        products = data.products.map({ ProductRowModel(data: $0) })
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
