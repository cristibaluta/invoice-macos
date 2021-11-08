//
//  Invoice.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

struct InvoiceData: Codable, PropertyLoopable {
    
    var email: String
    var phone: String
    var web: String
    
    var invoice_series: String
    var invoice_nr: Int
    var invoice_date: String
    
    var client: CompanyDetails
    var contractor: CompanyDetails
    
    var products: [InvoiceProduct]
    var reports: [InvoiceReport]
    var currency: String
    var tva: Double
    var amount_total: Double
    
    var date: Date {
        return Date(yyyyMMdd: invoice_date) ?? Date()
    }
}

struct InvoiceProduct: Codable {
    var product_name: String
    var rate: Double
    var exchange_rate: Double
    var units: Double
    var units_name: String
    var amount_per_unit: Double
    var amount: Double
}

struct InvoiceReport: Codable {
    var project_name: String
    var group: String
    var description: String
    var duration: Double
}

struct CompanyDetails: Codable, PropertyLoopable {
    var name: String
    var orc: String
    var cui: String
    var address: String
    var county: String
    var bank_account: String
    var bank_name: String
}

protocol PropertyLoopable {
    func allProperties() -> [String]
}

extension PropertyLoopable {
    func allProperties() -> [String] {

        var result: [String] = []
        let mirror = Mirror(reflecting: self)

        // Optional check to make sure we're iterating over a struct or class
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return []
        }

        for (property, _) in mirror.children {
            guard let property = property else {
                continue
            }
            result.append(property)
        }

        return result
    }
}
