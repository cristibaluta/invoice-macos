//
//  SettingsData.swift
//  Invoices
//
//  Created by Cristian Baluta on 12.01.2024.
//

import Foundation
import Combine
import RCPreferences

struct RepositoryOption: Identifiable, Hashable {
    let id = UUID()
    let type: RepositoryType
    var isOn = false
}

class SettingsStore: ObservableObject {

    @Published var repositories: [RepositoryOption]
    @Published var selection: RepositoryOption.ID?
    @Published var mainRepositoryType: RepositoryType
    @Published var backupRepositoryType: RepositoryType
    @Published var mainRepository: Repository
    @Published var backupRepository: Repository?
    @Published var mainRepositoryUrl: String = ""
    @Published var backupRepositoryUrl: String = ""
    @Published var enableBackup: Bool
    private var enableBackupCancellable: AnyCancellable?

    private var pref = RCPreferences<UserPreferences>()

    init(mainRepository: Repository, backupRepository: Repository?) {
        repositories = [
            RepositoryOption(type: .sandbox),
            RepositoryOption(type: .icloud),
            RepositoryOption(type: .custom)
        ]
        mainRepositoryType = RepositoryType(rawValue: pref.int(.repository)) ?? .sandbox
        backupRepositoryType = RepositoryType(rawValue: pref.int(.backupRepository)) ?? .custom
        self.mainRepository = mainRepository
        self.backupRepository = backupRepository
        enableBackup = pref.int(.backupRepository) != -1
        #if os(macOS)
        mainRepositoryUrl = (mainRepository as? LocalRepository)?.baseUrl?.absoluteString ?? ""
        backupRepositoryUrl = (backupRepository as? LocalRepository)?.baseUrl?.absoluteString ?? ""

        enableBackupCancellable = $enableBackup.sink { isOn in
            self.backupRepositoryType = isOn ? (RepositoryType(rawValue: self.pref.int(.backupRepository)) ?? .custom) : .custom
            self.pref.set(isOn ? 2 : -1, forKey: .backupRepository)
        }
        #else
        repositories.removeLast()
        if let ndx = repositories.firstIndex(where: { $0.type == currentRepository }) {
            repositories[ndx].isOn = true
            selection = repositories[ndx].id
        }
        #endif
    }

    func setMainRepository(_ repositoryType: RepositoryType) {
        mainRepositoryType = repositoryType
        pref.set(repositoryType.rawValue, forKey: .repository)
    }

    func setBackupRepository(_ repositoryType: RepositoryType) {
        backupRepositoryType = repositoryType
        pref.set(repositoryType.rawValue, forKey: .backupRepository)
    }

    func setMainUrl(_ url: URL) {
        mainRepositoryUrl = url.absoluteString
        pref.set(mainRepositoryType.rawValue, forKey: .repository)
        (mainRepository as? LocalRepository)?.baseUrl = url
    }

    func setBackupUrl(_ url: URL) {
        backupRepositoryUrl = url.absoluteString
        pref.set(backupRepositoryType.rawValue, forKey: .backupRepository)
        (backupRepository as? LocalRepository)?.baseUrl = url
    }
}
