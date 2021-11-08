//
//  InvoiceDetailsStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI
import AppKit

class InvoiceEditingStore: ObservableObject {
    
    @Published var email: String {
        didSet {
            data.email = email
        }
    }
    @Published var phone: String {
        didSet {
            data.phone = phone
        }
    }
    @Published var web: String {
        didSet {
            data.web = web
        }
    }
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
            data.invoice_date = date.ddMMMyyyy
        }
    }
    @Published var rate: String {
        didSet {
            data.products[0].rate = Double(rate) ?? 0
        }
    }
    @Published var exchangeRate: String {
        didSet {
            data.products[0].exchange_rate = Double(exchangeRate) ?? 0
        }
    }
    @Published var units: String {
        didSet {
            data.products[0].units = Double(units) ?? 0
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
    @Published var tva: String {
        didSet {
            data.tva = Double(tva) ?? 0
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
    
    init (data: InvoiceData) {
        self.data = data
        email = data.email
        phone = data.phone
        web = data.web
        invoiceSeries = data.invoice_series
        invoiceNr = String(data.invoice_nr)
        date = Date(yyyyMMdd: data.invoice_date) ?? Date()
        tva = String(data.tva)
        clientData = data.client
        contractorData = data.contractor
        
        rate = String(data.products[0].rate)
        exchangeRate = String(data.products[0].exchange_rate)
        units = String(data.products[0].units)
        unitsName = data.products[0].units_name
        productName = data.products[0].product_name
    }
}
