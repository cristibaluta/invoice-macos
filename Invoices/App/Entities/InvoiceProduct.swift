//
//  InvoiceProduct.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.01.2022.
//

import Foundation

// A product is one line in the invoice
struct InvoiceProduct: Codable, Equatable {
    
    var product_name: String
    var rate: Decimal
    var exchange_rate: Decimal
    var units: Decimal
    var units_name: String
    var amount_per_unit: Decimal
    var amount: Decimal
    
    enum CodingKeys: CodingKey {
        case product_name, rate, exchange_rate, units, units_name, amount_per_unit, amount
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(product_name, forKey: .product_name)
        try container.encode(rate.stringValue, forKey: .rate)
        try container.encode(exchange_rate.stringValue, forKey: .exchange_rate)
        try container.encode(units.stringValue, forKey: .units)
        try container.encode(units_name, forKey: .units_name)
        try container.encode(amount_per_unit.stringValue, forKey: .amount_per_unit)
        try container.encode(amount.stringValue, forKey: .amount)
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        product_name = try container.decode(String.self, forKey: .product_name)
        rate = Decimal(string: try container.decode(String.self, forKey: .rate)) ?? 0
        exchange_rate = Decimal(string: try container.decode(String.self, forKey: .exchange_rate)) ?? 0
        units = Decimal(string: try container.decode(String.self, forKey: .units)) ?? 0
        units_name = try container.decode(String.self, forKey: .units_name)
        amount_per_unit = Decimal(string: try container.decode(String.self, forKey: .amount_per_unit)) ?? 0
        amount = Decimal(string: try container.decode(String.self, forKey: .amount)) ?? 0
    }
    
    init (product_name: String,
          rate: Decimal,
          exchange_rate: Decimal,
          units: Decimal,
          units_name: String,
          amount_per_unit: Decimal,
          amount: Decimal) {
        
        self.product_name = product_name
        self.rate = rate
        self.exchange_rate = exchange_rate
        self.units = units
        self.units_name = units_name
        self.amount_per_unit = amount_per_unit
        self.amount = amount
    }
}
