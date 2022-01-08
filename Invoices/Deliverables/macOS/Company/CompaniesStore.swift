//
//  CompaniesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import Foundation

final class CompaniesStore: ObservableObject {
    
    var companyDetailsStore: CompanyDetailsStore
    @Published var companies: [CompanyData] = []
    @Published var selectedCompany: CompanyData? {
        didSet {
            if let data = selectedCompany {
                self.companyDetailsStore = CompanyDetailsStore(data: data)
            }
        }
    }
    
    init (data: CompanyData?) {
        let data = data ?? CompaniesManager.shared.emptyCompanyDetails
        self.companyDetailsStore = CompanyDetailsStore(data: data)
        reload()
    }
    
    func reload() {
        CompaniesManager.shared.getCompanies() { companies in
            self.companies = companies
        }
    }
}
