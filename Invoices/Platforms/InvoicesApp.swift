//
//  InvoicesApp.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI

@main
struct InvoicesApp: App {

//    private let store = MainStore(repository: SandboxRepository())
    private let store = MainStore(repository: IcloudDriveRepository())


    var body: some Scene {

        WindowGroup {
            MainWindow()
            .environmentObject(store)
            .environmentObject(store.companiesStore)
            .environmentObject(store.settingsStore)
        }
        .commands {
            SidebarCommands()
        }

        #if os(macOS)
        Settings {
            SettingsWindow()
            .environmentObject(store.settingsStore)
        }
        #endif
    }

}
