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
    
    enum CodingKeys: CodingKey {
        case invoice_series, invoice_nr, invoice_date, client, contractor, products, reports, currency, vat, amount_total, amount_total_vat
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(invoice_series, forKey: .invoice_series)
        try container.encode(invoice_nr, forKey: .invoice_nr)
        try container.encode(invoice_date, forKey: .invoice_date)
        try container.encode(client, forKey: .client)
        try container.encode(contractor, forKey: .contractor)
        try container.encode(products, forKey: .products)
        try container.encode(reports, forKey: .reports)
        try container.encode(currency, forKey: .currency)
        try container.encode(vat.stringValue, forKey: .vat)
        try container.encode(amount_total.stringValue, forKey: .amount_total)
        try container.encode(amount_total_vat.stringValue, forKey: .amount_total_vat)
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        invoice_series = try container.decode(String.self, forKey: .invoice_series)
        invoice_nr = try container.decode(Int.self, forKey: .invoice_nr)
        invoice_date = try container.decode(String.self, forKey: .invoice_date)
        client = try container.decode(CompanyDetails.self, forKey: .client)
        contractor = try container.decode(CompanyDetails.self, forKey: .contractor)
        products = try container.decode([InvoiceProduct].self, forKey: .products)
        reports = try container.decode([InvoiceReport].self, forKey: .reports)
        currency = try container.decode(String.self, forKey: .currency)
        vat = Decimal(string: try container.decode(String.self, forKey: .vat)) ?? 0
        amount_total = Decimal(string: try container.decode(String.self, forKey: .amount_total)) ?? 0
        amount_total_vat = Decimal(string: try container.decode(String.self, forKey: .amount_total_vat)) ?? 0
    }
    
    init (invoice_series: String,
          invoice_nr: Int,
          invoice_date: String,
          client: CompanyDetails,
          contractor: CompanyDetails,
          products: [InvoiceProduct],
          reports: [InvoiceReport],
          currency: String,
          vat: Decimal,
          amount_total: Decimal,
          amount_total_vat: Decimal) {
        self.invoice_series = invoice_series
        self.invoice_nr = invoice_nr
        self.invoice_date = invoice_date
        self.client = client
        self.contractor = contractor
        self.products = products
        self.reports = reports
        self.currency = currency
        self.vat = vat
        self.amount_total = amount_total
        self.amount_total_vat = amount_total_vat
    }
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
            if key == "amount_total" || key == "amount_total_vat", let amount = Decimal(string: value as? String ?? "") {
                template = template.replacingOccurrences(of: "::\(key)::", with: "\(amount.stringValue_grouped2)")
            }
            else if key == "invoice_date", let date = Date(yyyyMMdd: value as? String ?? "") {
                template = template.replacingOccurrences(of: "::\(key)::", with: "\(date.mediumDate)")
            }
            else if key == "invoice_nr" {
                template = template.replacingOccurrences(of: "::\(key)::", with: self.invoice_nr.prefixedWith0)
            }
            else if key == "contractor" || key == "client", let dic = value as? [String: Any] {
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
            // We know the total amount vat
            // We calculate the amount and the units
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
