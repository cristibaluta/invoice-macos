//
//  Formatter.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

extension Double {
    
    var stringFormatWith2Digits: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","

        let number = NSNumber(value: self)
        return formatter.string(from: number)!
    }
    var stringFormatWith4Digits: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","

        let number = NSNumber(value: self)
        return formatter.string(from: number)!
    }
    
    var roundTo2Digits: Double {
        return (self * 100).rounded() / 100.0
    }
    var roundTo4Digits: Double {
        return (self * 10000).rounded() / 10000.0
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
