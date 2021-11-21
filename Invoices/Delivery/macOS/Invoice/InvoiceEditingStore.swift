//
//  InvoiceDetailsStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI
import AppKit

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
            data.products[0].rate = Decimal(Double(rate) ?? 0)
        }
    }
    @Published var exchangeRate: String {
        didSet {
            data.products[0].exchange_rate = Decimal(Double(exchangeRate) ?? 0)
        }
    }
    @Published var units: String {
        didSet {
            data.products[0].units = Decimal(Double(units) ?? 0)
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
            data.vat = Decimal(Double(vat) ?? 0)
        }
    }
    @Published var amountTotalVat: String {
        didSet {
            data.amount_total_vat = Decimal(Double(amountTotalVat) ?? 0)
        }
    }
    @Published var isEditingTotal: Bool = false
    
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
    
    init (data: InvoiceData) {
        self.data = data
        invoiceSeries = data.invoice_series
        invoiceNr = String(data.invoice_nr)
        date = Date(yyyyMMdd: data.invoice_date) ?? Date()
        vat = data.vat.stringFormatWith2Digits
        amountTotalVat = data.amount_total_vat.stringFormatWith2Digits
        clientData = data.client
        contractorData = data.contractor
        
        rate = data.products[0].rate.stringFormatWith2Digits
        exchangeRate = data.products[0].exchange_rate.stringFormatWith4Digits
        units = data.products[0].units.stringFormatWith2Digits
        unitsName = data.products[0].units_name
        productName = data.products[0].product_name
    }
}
