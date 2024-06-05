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
            case .custom: mainRepository = LocalRepository(.main)
            #endif
            default: mainRepository = SandboxRepository()
        }

        let backupRepository: Repository?
        switch RepositoryType(rawValue: pref.int(.backupRepository)) {
            case .sandbox: backupRepository = SandboxRepository()
            case .icloud: backupRepository = IcloudDriveRepository()
            #if os(macOS)
            case .custom: backupRepository = LocalRepository(.backup)
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
        settingsStore = SettingsStore(mainRepository: mainRepository, backupRepository: backupRepository)

        projectsStore.changePublisher
            .sink {
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
