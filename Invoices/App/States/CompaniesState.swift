//
//  CompaniesState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine

class CompaniesState: ObservableObject {

    @Published var companiesData: [CompanyData] = []
    @Published var companies: [Company] = []
    var selectedCompany: CompanyData? {
        didSet {
            print(">>>>>>>>> selected new company \(String(describing: selectedCompany))")
        }
    }
    @Published var isShowingNewCompanySheet = false

    let interactor: CompaniesInteractor


    init (interactor: CompaniesInteractor) {
        self.interactor = interactor
        print("init CompaniesState")
    }

    func refresh() {
        _ = interactor.refreshCompaniesList()
        .print("CompaniesState")
        .sink { [weak self] in
            self?.companiesData = $0
            self?.companies = $0.map { Company(name: $0.name, data: $0) }
        }
    }

    func saveSelectedCompany() {
        guard let comp = selectedCompany else {
            fatalError("No company is selected")
        }
        interactor.save(comp) { company in
            self.refresh()
            self.dismissNewCompany()
        }
    }

    func dismissNewCompany() {
        self.isShowingNewCompanySheet = false
    }
}