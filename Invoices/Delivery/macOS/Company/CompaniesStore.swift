//
//  CompaniesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import Foundation

final class CompaniesStore: ObservableObject {
    var data: CompanyDetails
    
    init (data: CompanyDetails?) {
        self.data = data ?? CompaniesManager.shared.emptyCompanyDetails
    }
    
    func save (completion: () -> Void) {
        CompaniesManager.shared.save(data) { _ in
            completion()
        }
    }
}
