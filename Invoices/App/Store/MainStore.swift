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

class MainStore: ObservableObject {

    var projectsStore: ProjectsStore
    var companiesStore: CompaniesStore
    var settingsStore: SettingsStore

    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init (repository: Repository) {
        projectsStore = ProjectsStore(repository: repository)
        companiesStore = CompaniesStore(repository: repository)
        settingsStore = SettingsStore()

        projectsStore.projectDidChangePublisher
            .sink {
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        projectsStore.chartDidChangePublisher
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
