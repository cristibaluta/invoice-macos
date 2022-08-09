//
//  CompaniesInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine

class CompaniesInteractor {

    static var emptyCompanyDetails: CompanyData {
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

    private let repository: Repository

    private var companiesUrl: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("companies.json")
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }


    init (repository: Repository) {
        self.repository = repository
    }

    func refreshCompaniesList() -> AnyPublisher<[CompanyData], Never> {
        return repository
            .readFile(at: companiesUrl)
            .decode(type: [CompanyData].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private func company (for cui: String) -> AnyPublisher<CompanyData?, Never> {
        return refreshCompaniesList()
            .compactMap {
                $0.filter { data in
                    return data.cui == cui
                }.first
            }
            .eraseToAnyPublisher()
    }

    func save (_ company: CompanyData, completion: @escaping (Bool) -> Void) {
        _ = refreshCompaniesList()
        .compactMap {
            var companies: [CompanyData] = $0
            var found = false
            if companies.count > 0 {
                for i in 0..<companies.count {
                    if company.cui == companies[i].cui {
                        companies[i] = company
                        found = true
                        break
                    }
                }
            }
            if !found {
                companies.append(company)
            }
            return companies
        }
//        .encode(encoder: encoder)
//        .sink { companies in
//            print(companies)
//        } receiveValue: { json in
//            print(json)
//        }
        .sink { (companies: [CompanyData]) in
            self.save(companies, completion: completion)
        }
    }

    func save (_ companies: [CompanyData], completion: @escaping (Bool) -> Void) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(companies)
            _ = repository.writeFile(jsonData, at: self.companiesUrl)
            completion(true)
        }
        catch {
            completion(false)
        }
    }
}
