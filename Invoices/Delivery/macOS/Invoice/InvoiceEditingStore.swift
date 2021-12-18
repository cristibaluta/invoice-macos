//
//  InvoiceDetailsStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI

class InvoiceEditingStore: ObservableObject {
    
    @Published var invoiceSeries: String {
        didSet {
            data.invoice_series = invoiceSeries
        }
    }
    @Published var invoiceNr: String {
        didSet {
            data.invoice_nr = Int(invoiceNr) ?? 0
        }
    }
    @Published var date: Date {
        didSet {
            data.invoice_date = date.yyyyMMdd
        }
    }
    
    @Published var rate: String {
        didSet {
            data.products[0].rate = Decimal(string: rate) ?? 0
        }
    }
    @Published var exchangeRate: String {
        didSet {
            data.products[0].exchange_rate = Decimal(string: exchangeRate) ?? 0
        }
    }
    @Published var units: String {
        didSet {
            data.products[0].units = Decimal(string: units) ?? 0
            data.calculate()
            if !isFixedTotal {
                amountTotalVat = data.amount_total_vat.stringValue_2
            }
        }
    }
    @Published var unitsName: String {
        didSet {
            data.products[0].units_name = unitsName
        }
    }
    @Published var productName: String {
        didSet {
            data.products[0].product_name = productName
        }
    }
    @Published var vat: String {
        didSet {
            data.vat = Decimal(string: vat) ?? 0
        }
    }
    @Published var amountTotalVat: String {
        didSet {
            if isFixedTotal {
                data.amount_total_vat = Decimal(string: amountTotalVat) ?? 0
                data.calculate()
                units = data.products[0].units.stringValue
            }
        }
    }
    @Published var isFixedTotal: Bool = false {
        didSet {
            data.isFixedTotal = isFixedTotal
        }
    }
    
    var clientData: CompanyDetails {
        didSet {
            data.client = clientData
        }
    }
    var contractorData: CompanyDetails {
        didSet {
            data.contractor = contractorData
        }
    }
    
    var data: InvoiceData
    var isInitStage = true
    
    init (data: InvoiceData) {
        self.data = data
        invoiceSeries = data.invoice_series
        invoiceNr = String(data.invoice_nr)
        date = Date(yyyyMMdd: data.invoice_date) ?? Date()
        vat = data.vat.stringValue_2
        amountTotalVat = data.amount_total_vat.stringValue_2
        clientData = data.client
        contractorData = data.contractor
        
        rate = data.products[0].rate.stringValue_2
        exchangeRate = data.products[0].exchange_rate.stringValue_4
        units = data.products[0].units.stringValue
        unitsName = data.products[0].units_name
        productName = data.products[0].product_name
        
        isInitStage = false
    }
}
