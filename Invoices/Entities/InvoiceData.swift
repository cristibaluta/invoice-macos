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
    var vat: Decimal
    var amount_total: Decimal
    var amount_total_vat: Decimal
    
    // This will trigger the units to be calculated instead the amount_total_vat
    var isFixedTotal: Bool?
}

extension InvoiceData {
    
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
            if key == "amount_total" || key == "amount_total_vat" {
                // Somethimes it comes as NSNumber instead Decimal
                if let amount = value as? Decimal {
                    template = template.replacingOccurrences(of: "::\(key)::", with: "\(amount.stringValue_grouped2)")
                }
                else if let amount = value as? NSNumber {
                    template = template.replacingOccurrences(of: "::\(key)::", with: "\(amount.decimalValue.stringValue_grouped2)")
                }
            }
            else if key == "invoice_date", let date = Date(yyyyMMdd: value as? String ?? "") {
                template = template.replacingOccurrences(of: "::\(key)::", with: "\(date.mediumDate)")
            }
            else if key == "invoice_nr" {
                template = template.replacingOccurrences(of: "::\(key)::", with: self.invoice_nr.prefixedWith0)
            }
            else if key == "contractor", let dic = value as? [String: Any] {
                for (k, v) in dic {
                    template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                }
            }
            else if key == "client", let dic = value as? [String: Any] {
                for (k, v) in dic {
                    template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                }
            }
            else {
                template = template.replacingOccurrences(of: "::\(key)::", with: "\(value)")
            }
        }
        return template
    }
    
    mutating func calculate() {
        var products = [InvoiceProduct]()
        /// Calculate the amount
        if isFixedTotal == true {
            // We know the total amount
            // We calculate the units
            amount_total = amount_total_vat / (1 + (vat / 100))

            for var product in self.products {
                product.amount_per_unit = product.rate * product.exchange_rate
                product.units = amount_total / product.amount_per_unit
                product.amount = amount_total
                products.append(product)
            }
        }
        else {
            // We know the units
            // We calculate the total amount
            var total: Decimal = 0.0
            
            for var product in self.products {
                let amount_per_unit = product.rate * product.exchange_rate
                let amount = product.units * amount_per_unit
                total += amount
                
                product.amount_per_unit = amount_per_unit
                product.amount = amount
                products.append(product)
            }
            
            amount_total = total
            amount_total_vat = amount_total + amount_total * vat / 100
        }
        self.products = products
    }
}

struct InvoiceProduct: Codable {
    var product_name: String
    var rate: Decimal
    var exchange_rate: Decimal
    var units: Decimal
    var units_name: String
    var amount_per_unit: Decimal
    var amount: Decimal
}

struct InvoiceReport: Codable {
    var project_name: String
    var group: String?
    var description: String
    var duration: Decimal
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
