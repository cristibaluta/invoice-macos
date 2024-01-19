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

    private let companiesPath: String = "companies.json"

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }


    init (repository: Repository) {
        self.repository = repository
    }

    func loadCompaniesList() -> AnyPublisher<[CompanyData], Never> {
        return repository
            .readFile(at: companiesPath)
            .decode(type: [CompanyData].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private func company (for cui: String) -> AnyPublisher<CompanyData?, Never> {
        return loadCompaniesList()
            .compactMap {
                $0.filter { data in
                    return data.cui == cui
                }.first
            }
            .eraseToAnyPublisher()
    }

    func save (_ company: CompanyData) -> AnyPublisher<Bool, Never> {

        return loadCompaniesList()
            .map {
                var companies: [CompanyData] = $0
                if let index = companies.firstIndex(where: { company.cui == $0.cui }) {
                    companies[index] = company
                } else {
                    companies.append(company)
                }
                return companies
            }
            .encode(encoder: encoder)
            .replaceError(with: Data())
            .flatMap { jsonData in
                return self.repository.writeFile(jsonData, at: self.companiesPath)
            }
            .eraseToAnyPublisher()
    }

    func delete (_ company: CompanyData) -> AnyPublisher<Bool, Never> {

        return loadCompaniesList()
            .map {
                var companies: [CompanyData] = $0
                if let index = companies.firstIndex(where: { company.cui == $0.cui }) {
                    companies.remove(at: index)
                }
                return companies
            }
            .encode(encoder: encoder)
            .replaceError(with: Data())
            .flatMap { jsonData in
                return self.repository.writeFile(jsonData, at: self.companiesPath)
            }
            .eraseToAnyPublisher()
    }
}
