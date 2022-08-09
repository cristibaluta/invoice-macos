//
//  Company.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import Foundation

struct Company: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var data: CompanyData
}
