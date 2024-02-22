//
//  ProductRowModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 22.02.2024.
//

import Foundation
import Combine

class ProductRowModel: ObservableObject, Identifiable {

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
        print(">>>>> init ProductRowModel")
        self.data = data

        productName = data.product_name
        rate = data.rate.stringValue_2
        exchangeRate = data.exchange_rate.stringValue_4
        unitsName = data.units_name
        units = data.units.stringValue
        amount = data.amount.stringValue_2

        $productName.removeDuplicates().sink { [weak self] newValue in
            self?.data.product_name = newValue
        }
        .store(in: &cancellables)

        $rate.removeDuplicates().sink { [weak self] newValue in
            print(">>>>>> rate.sink \(newValue)")
            self?.data.rate = Decimal(string: newValue) ?? 0
            self?.calculateAmount()
        }
        .store(in: &cancellables)

        $exchangeRate.removeDuplicates().sink { [weak self] newValue in
            print(">>>>>> exchangerate.sink \(newValue)")
            self?.data.exchange_rate = Decimal(string: newValue) ?? 0
            self?.calculateAmount()
        }
        .store(in: &cancellables)

        //        .assign(to: \.units_name, on: self.data)
        $unitsName.removeDuplicates().sink { [weak self] newValue in
            self?.data.units_name = newValue
        }
        .store(in: &cancellables)

        $units.removeDuplicates().sink { [weak self] newValue in
            print(">>>>>> units.sink \(newValue)")
            self?.data.units = Decimal(string: newValue) ?? 0
            self?.calculateAmount()
        }
        .store(in: &cancellables)
    }

    deinit {
        print("<<<<< deinit ProductRowModel")
        cancellables.removeAll()
    }

    private func calculateAmount() {
        data.calculate()
        amount = data.amount.stringValue_2
    }
}
