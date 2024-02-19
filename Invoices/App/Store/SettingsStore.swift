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
}

class SettingsStore: ObservableObject {

    @Published var repositories: [RepositoryOption]
    @Published var currentRepository: RepositoryType
    @Published var backupRepository: RepositoryType
    @Published var backupRepositoryUrl: String
    @Published var enableBackup: Bool
    private var enableBackupCancellable: AnyCancellable?

    private var pref = RCPreferences<UserPreferences>()

    init() {
        repositories = [
            RepositoryOption(type: .sandbox),
            RepositoryOption(type: .icloud),
            RepositoryOption(type: .custom)
        ]
        currentRepository = RepositoryType(rawValue: pref.int(.repository)) ?? .sandbox
        backupRepository = RepositoryType(rawValue: pref.int(.backupRepository)) ?? .custom
        enableBackup = pref.int(.backupRepository) != -1
        backupRepositoryUrl = LocalRepository.getBaseUrlBookmark()?.absoluteString ?? ""

        enableBackupCancellable = $enableBackup.sink { isOn in
            self.backupRepository = isOn ? (RepositoryType(rawValue: self.pref.int(.backupRepository)) ?? .custom) : .custom
            self.pref.set(isOn ? 2 : -1, forKey: .backupRepository)
        }
    }

    func setCurrentRepository(_ repository: RepositoryType) {
        currentRepository = repository
        pref.set(repository.rawValue, forKey: .repository)
    }

    func setBackupUrl(_ url: URL) {
        backupRepository = .custom
        backupRepositoryUrl = url.absoluteString
        pref.set(backupRepository.rawValue, forKey: .backupRepository)
    }
}
