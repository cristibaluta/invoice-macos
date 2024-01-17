//
//  CompaniesState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

class CompaniesStore: ObservableObject {

    @Published var companiesData: [CompanyData] = []
    @Published var companies: [Company] = []
    var selectedCompany: CompanyData? {
        didSet {
            print(">>>>>>>>> selected new company \(String(describing: selectedCompany))")
        }
    }
    @Published var isShowingNewCompanySheet = false

    private let interactor: CompaniesInteractor

    init (repository: Repository) {
        self.interactor = CompaniesInteractor(repository: repository)
    }

    func refresh() {
        _ = interactor.loadCompaniesList()
        .sink { [weak self] in
            self?.companiesData = $0
            self?.companies = $0.map { Company(name: $0.name, data: $0) }
        }
    }

    func saveSelectedCompany() {
        guard let comp = selectedCompany else {
            fatalError("No company is selected")
        }
        _ = interactor.save(comp)
            .sink { success in
                self.refresh()
                self.dismissNewCompany()
            }
    }

    func dismissNewCompany() {
        self.isShowingNewCompanySheet = false
    }
}
