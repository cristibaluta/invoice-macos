//
//  AppState.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import SwiftUI
import Combine

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

        projectsStore.changePublisher
            .sink {
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
