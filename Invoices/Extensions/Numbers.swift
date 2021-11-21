//
//  Formatter.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

extension Decimal {
    
    var stringFormatWith2Digits: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
//        formatter.numberStyle = .currency
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","

        return formatter.string(from: self as NSDecimalNumber) ?? "-"
    }
    var stringFormatWith4Digits: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
//        formatter.numberStyle = .currency
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","

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
