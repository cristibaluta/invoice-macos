//
//  Invoice.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

struct InvoiceData: Codable, PropertyLoopable {
    
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
    
    func toHtmlUsingTemplate (_ template: String) -> String {
        /// Convert enum to dict
        guard let data = try? JSONEncoder().encode(self) else { return "" }
        let dict: [String: Any]? = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
                .flatMap { $0 as? [String: Any] }
        var template = template
        for (key, value) in (dict ?? [:]) {
            guard key != "amount" && key != "amount_total" else {
                // This values are calculated
                continue
            }
            if key == "invoice_date", let date = Date(yyyyMMdd: value as? String ?? "") {
                template = template.replacingOccurrences(of: "::\(key)::", with: "\(date.mediumDate)")
            }
            else if key == "invoice_nr" {
                template = template.replacingOccurrences(of: "::\(key)::", with: self.invoice_nr.prefixedWith0)
            }
            else if key == "contractor", let dic = value as? [String: Any] {
                for (k, v) in dic {
                    template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                }
            } else if key == "client", let dic = value as? [String: Any] {
                for (k, v) in dic {
                    template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                }
            } else {
                template = template.replacingOccurrences(of: "::\(key)::", with: "\(value)")
            }
        }
        return template
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
    var group: String?
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
    var email: String?
    var phone: String?
    var web: String?
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
