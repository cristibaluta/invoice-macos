//
//  Invoice.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

struct InvoiceData: Codable, Equatable, PropertyLoopable {

    var invoice_series: String
    var invoice_nr: Int
    var invoice_date: String
    var invoiced_period: String

    var client: CompanyData
    var contractor: CompanyData
    
    var products: [InvoiceProduct]
    var reports: [InvoiceReport]
    var currency: String
    var vat_percent: Decimal
    var vat_amount: Decimal
    var amount_total: Decimal
    var amount_total_vat: Decimal
    
    /// This will trigger the units to be calculated instead the amount_total_vat
    var isFixedTotal: Bool?
    
    enum CodingKeys: CodingKey {
        case invoice_series, invoice_nr, invoice_date, invoiced_period,
             client, contractor,
             products,
             reports,
             currency, vat_percent, vat_amount, amount_total, amount_total_vat
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(invoice_series, forKey: .invoice_series)
        try container.encode(invoice_nr, forKey: .invoice_nr)
        try container.encode(invoice_date, forKey: .invoice_date)
        try container.encode(invoiced_period, forKey: .invoiced_period)
        try container.encode(client, forKey: .client)
        try container.encode(contractor, forKey: .contractor)
        try container.encode(products, forKey: .products)
        try container.encode(reports, forKey: .reports)
        try container.encode(currency, forKey: .currency)
        try container.encode(vat_percent.stringValue, forKey: .vat_percent)
        try container.encode(vat_amount.stringValue, forKey: .vat_amount)
        try container.encode(amount_total.stringValue, forKey: .amount_total)
        try container.encode(amount_total_vat.stringValue, forKey: .amount_total_vat)
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        invoice_series = try container.decode(String.self, forKey: .invoice_series)
        invoice_nr = try container.decode(Int.self, forKey: .invoice_nr)
        invoice_date = try container.decode(String.self, forKey: .invoice_date)
        invoiced_period = try container.decodeIfPresent(String.self, forKey: .invoiced_period) ?? invoice_date
        client = try container.decode(CompanyData.self, forKey: .client)
        contractor = try container.decode(CompanyData.self, forKey: .contractor)
        products = try container.decode([InvoiceProduct].self, forKey: .products)
        reports = try container.decode([InvoiceReport].self, forKey: .reports)
        currency = try container.decode(String.self, forKey: .currency)
        vat_percent = Decimal(string: (try? container.decode(String.self, forKey: .vat_percent)) ?? "0") ?? 0
        vat_amount = Decimal(string: (try? container.decode(String.self, forKey: .vat_amount)) ?? "0") ?? 0
        amount_total = Decimal(string: try container.decode(String.self, forKey: .amount_total)) ?? 0
        amount_total_vat = Decimal(string: try container.decode(String.self, forKey: .amount_total_vat)) ?? 0
    }
    
    init (invoice_series: String,
          invoice_nr: Int,
          invoice_date: String,
          invoiced_period: String,
          client: CompanyData,
          contractor: CompanyData,
          products: [InvoiceProduct],
          reports: [InvoiceReport],
          currency: String,
          vat_percent: Decimal,
          vat_amount: Decimal,
          amount_total: Decimal,
          amount_total_vat: Decimal) {

        self.invoice_series = invoice_series
        self.invoice_nr = invoice_nr
        self.invoice_date = invoice_date
        self.invoiced_period = invoiced_period
        self.client = client
        self.contractor = contractor
        self.products = products
        self.reports = reports
        self.currency = currency
        self.vat_percent = vat_percent
        self.vat_amount = vat_amount
        self.amount_total = amount_total
        self.amount_total_vat = amount_total_vat
    }
}

extension InvoiceData {
    
    var date: Date {
        return Date(yyyyMMdd: invoice_date) ?? Date()
    }
    
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        let dict: [String: Any]? = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            .flatMap { $0 as? [String: Any] }
        return dict ?? [:]
    }

    mutating func calculate() {
        /// Calculate the total amount
        if isFixedTotal == true {
            // We know the total amount vat
            // We calculate the amount and the units
//            amount_total = amount_total_vat / (1 + (vat / 100))
//
//            for var product in self.products {
//                product.amount_per_unit = product.rate * product.exchange_rate
//                product.units = amount_total / product.amount_per_unit
//                product.amount = amount_total
//                products.append(product)
//            }
        } else {
            // We know the units
            // We calculate the total amount
            var total: Decimal = 0.0

            for i in 0..<products.count {
                products[i].calculate()
                total += products[i].amount
            }

            amount_total = total
            vat_amount = amount_total * vat_percent / 100
            amount_total_vat = amount_total + vat_amount
        }
    }

}
