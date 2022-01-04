//
//  CompaniesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import Foundation

final class CompaniesStore: ObservableObject {
    
    var data: CompanyDetails
    var companyDetailsStore: CompanyDetailsStore
    
    init (data: CompanyDetails?) {
        self.data = data ?? CompaniesManager.shared.emptyCompanyDetails
        self.companyDetailsStore = CompanyDetailsStore(data: self.data)
    }
}
