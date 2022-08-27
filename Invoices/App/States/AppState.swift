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

    var foldersState: FoldersState
    var invoicesState: InvoicesState
    var companiesState: CompaniesState


    init (repository: Repository) {
        self.repository = repository
        self.foldersState = FoldersState(interactor: FoldersInteractor(repository: repository))
        self.invoicesState = InvoicesState(invoicesInteractor: InvoicesInteractor(repository: repository),
                                           reportsInteractor: ReportsInteractor(repository: repository))
        self.companiesState = CompaniesState(interactor: CompaniesInteractor(repository: repository))
    }
}
