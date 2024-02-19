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

        let mainRepository: Repository
        switch RepositoryType(rawValue: pref.int(.repository)) {
            case .sandbox: mainRepository = SandboxRepository()
            case .icloud: mainRepository = IcloudDriveRepository()
            #if os(macOS)
            case .custom: mainRepository = LocalRepository()
            #endif
            default: mainRepository = SandboxRepository()
        }

        let backupRepository: Repository?
        switch RepositoryType(rawValue: pref.int(.repository)) {
            #if os(macOS)
            case .sandbox: backupRepository = LocalRepository()
            #endif
            default: backupRepository = nil
        }

        let repository: Repository
        if let backupRepository {
            repository = BackupRepository(mainRepository: mainRepository, backupRepository: backupRepository)
        } else {
            repository = mainRepository
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
