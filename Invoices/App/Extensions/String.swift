//
//  String.swift
//  Invoices
//
//  Created by Cristian Baluta on 14.02.2024.
//

import Foundation

extension String {
    var alphanumeric: String {
        return self
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
    }
}
