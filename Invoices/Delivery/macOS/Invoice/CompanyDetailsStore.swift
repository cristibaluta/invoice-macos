//
//  CompanyDetailsStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.11.2021.
//

import SwiftUI

class CompanyDetailsStore: ObservableObject {
    
    @Published var name: String {
        didSet {
            data.name = name
        }
    }
    @Published var orc: String {
        didSet {
            data.orc = orc
        }
    }
    @Published var cui: String {
        didSet {
            data.cui = cui
        }
    }
    @Published var address: String {
        didSet {
            data.address = address
        }
    }
    @Published var county: String {
        didSet {
            data.county = county
        }
    }
    @Published var bankAccount: String {
        didSet {
            data.bank_account = bankAccount
        }
    }
    @Published var bankName: String {
        didSet {
            data.bank_name = bankName
        }
    }
    
    var data: CompanyDetails
    
    init (data: CompanyDetails) {
        self.data = data
        
        name = data.name
        orc = data.orc
        cui = data.cui
        address = data.address
        county = data.county
        bankAccount = data.bank_account
        bankName = data.bank_name
    }
}
