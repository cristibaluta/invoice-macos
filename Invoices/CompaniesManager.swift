//
//  CompaniesManager.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import Foundation

class CompaniesManager {
    
    static let shared = CompaniesManager()
    
    var emptyCompanyDetails: CompanyData {
        return CompanyData(name: "",
                              orc: "",
                              cui: "",
                              address: "",
                              county: "",
                              bank_account: "",
                              bank_name: "",
                              email: nil,
                              phone: nil,
                              web: nil)
    }
    private var companies: [CompanyData] = []
    
    init() {
        
    }
    
    func getCompanies (completion: ([CompanyData]) -> Void) {
        
        AppFilesManager.default.executeInSelectedDir { url in
            let companiesUrl = url.appendingPathComponent("companies.json")
            do {
                let jsonData = try Data(contentsOf: companiesUrl)
                let companies = try JSONDecoder().decode([CompanyData].self, from: jsonData)
                self.companies = companies
                completion(companies)
            }
            catch {
                self.companies = []
                completion([])
            }
        }
    }
    
    func save (_ data: CompanyData, completion: (CompanyData?) -> Void) {
        getCompanies { companies in
            var companies = companies
            var found = false
            if companies.count > 0 {
                for i in 0..<companies.count {
                    if data.cui == companies[i].cui {
                        companies[i] = data
                        found = true
                        break
                    }
                }
            }
            if !found {
                companies.append(data)
            }
            AppFilesManager.default.executeInSelectedDir { url in
                let companiesUrl = url.appendingPathComponent("companies.json")
                do {
                    // Save json
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let jsonData = try encoder.encode(companies)
                    try jsonData.write(to: companiesUrl)
                    completion(data)
                }
                catch {
                    self.companies = []
                    completion(nil)
                }
            }
        }
    }
}
