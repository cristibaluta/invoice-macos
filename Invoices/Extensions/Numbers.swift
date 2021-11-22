//
//  Formatter.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

extension Decimal {
    
    var stringValue_grouped2: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","

        return formatter.string(from: self as NSDecimalNumber) ?? "-"
    }
    var stringValue_grouped4: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","

        return formatter.string(from: self as NSDecimalNumber) ?? "-"
    }
    
    var stringValue_2: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""

        return formatter.string(from: self as NSDecimalNumber) ?? "-"
    }
    var stringValue_4: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""

        return formatter.string(from: self as NSDecimalNumber) ?? "-"
    }
}

extension Int {
    var prefixedWith0: String {
        if self < 10 {
            return "00\(self)"
        } else if self < 100 {
            return "0\(self)"
        }
        return "\(self)"
    }
}
