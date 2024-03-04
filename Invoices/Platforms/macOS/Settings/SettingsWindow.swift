//
//  SettingsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 12.01.2024.
//

import Foundation
import SwiftUI

struct SettingsWindow: View {

    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                Text("Files location:")
                    .bold()

                HStack {
                    Menu {
                        ForEach(settingsStore.repositories) { repository in
                            Button(repository.type.name, action: {
                                settingsStore.setCurrentRepository(repository.type)
                            })
                        }
                    } label: {
                        Text(settingsStore.currentRepository.name)
                    }
                    Spacer()
                }

                HStack {
                    Toggle("Backup", isOn: $settingsStore.enableBackup)

                    if settingsStore.enableBackup {
                        Button("Chose path") {
                            let panel = NSOpenPanel()
                            panel.canChooseFiles = false
                            panel.canChooseDirectories = true
                            panel.allowsMultipleSelection = false
                            if panel.runModal() == .OK {
                                if let url = panel.urls.first {
                                    self.settingsStore.setBackupUrl(url)
                                }
                            }
                        }
                        .padding(.leading, 16)

                        Text(settingsStore.backupRepositoryUrl)
                    }
                }

                Button("Test ANAF") {
                    AnafRepository().getRefreshToken()
                }
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }
}
