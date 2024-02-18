//
//  AppState.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import SwiftUI
import Combine
import RCPreferences

class MainStore: ObservableObject {

    var projectsStore: ProjectsStore
    var companiesStore: CompaniesStore
    var settingsStore: SettingsStore

    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var pref = RCPreferences<UserPreferences>()

    init() {

        var repository: Repository
        switch RepositoryType(rawValue: pref.int(.repository)) {
            case .sandbox: repository = SandboxRepository()
            case .icloud: repository = IcloudDriveRepository()
            case .custom: repository = LocalRepository()
            default: repository = SandboxRepository()
        }

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
