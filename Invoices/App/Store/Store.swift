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

enum SegmentedControlType: Int {
    case invoice
    case report
}

class Store: ObservableObject {

    var projectsStore: ProjectsStore
    var companiesStore: CompaniesStore
    var settingsStore: SetingsStore

    init (repository: Repository) {
        self.projectsStore = ProjectsStore(repository: repository)
        self.companiesStore = CompaniesStore(repository: repository)
        self.settingsStore = SetingsStore()
    }
}
