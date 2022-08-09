//
//  CompanyDetails.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.01.2022.
//

import Foundation

struct CompanyData: Codable, Hashable, PropertyLoopable {
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
