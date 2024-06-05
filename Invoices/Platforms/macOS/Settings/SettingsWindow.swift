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

                VStack {
                    HStack {
                        Menu {
                            ForEach(settingsStore.repositories) { repository in
                                Button(repository.type.name, action: {
                                    settingsStore.setMainRepository(repository.type)
                                })
                            }
                        } label: {
                            Text(settingsStore.mainRepositoryType.name)
                        }
                        Spacer()
                    }
                    if settingsStore.mainRepositoryType == .custom {
                        HStack {
                            Button("Chose path") {
                                let panel = NSOpenPanel()
                                panel.canChooseFiles = false
                                panel.canChooseDirectories = true
                                panel.allowsMultipleSelection = false
                                if panel.runModal() == .OK {
                                    if let url = panel.urls.first {
                                        self.settingsStore.setMainUrl(url)
                                    }
                                }
                            }
                            Text(settingsStore.mainRepositoryUrl)
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }

                Spacer().frame(height: 40)
                
                Text("Backup files location:")
                    .bold()

                VStack {
                    HStack {
                        Toggle("Backup", isOn: $settingsStore.enableBackup)
                        Spacer()
                    }

                    if settingsStore.enableBackup {
                        HStack {
                            Menu {
                                ForEach(settingsStore.repositories) { repository in
                                    Button(repository.type.name, action: {
                                        settingsStore.setBackupRepository(repository.type)
                                    })
                                }
                            } label: {
                                Text(settingsStore.backupRepositoryType.name)
                            }
                            Spacer()
                        }
                        if settingsStore.backupRepositoryType == .custom {
                            HStack {
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
                                Text(settingsStore.backupRepositoryUrl)
                                Spacer()
                            }
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }
}
