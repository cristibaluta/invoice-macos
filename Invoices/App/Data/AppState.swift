//
//  AppState.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import SwiftUI
import Combine
import RCPreferences

#if os(macOS)
let appFont = Font.system(size: 12)
#else
let appFont = Font.system(.body)
#endif

enum UserPreferences: String, RCPreferencesProtocol {

    case lastProject = "lastProject"

    func defaultValue() -> Any {
        switch self {
            case .lastProject: return ""
        }
    }
}

class AppState: ObservableObject {

    private let repository: Repository

    var projectsData: ProjectsData
    var invoicesData: InvoicesData
    var companiesData: CompaniesData


    init (repository: Repository) {
        self.repository = repository
        self.projectsData = ProjectsData(interactor: ProjectsInteractor(repository: repository))
        self.invoicesData = InvoicesData(invoicesInteractor: InvoicesInteractor(repository: repository),
                                         reportsInteractor: ReportsInteractor(repository: repository))
        self.companiesData = CompaniesData(interactor: CompaniesInteractor(repository: repository))
    }
}
