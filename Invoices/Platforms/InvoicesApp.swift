//
//  InvoicesApp.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI

@main
struct InvoicesApp: App {

    private let states = AppState(repository: SandboxRepository())


    var body: some Scene {

        WindowGroup {
            MainView()
            .environmentObject(states.projectsState)
            .environmentObject(states.invoicesState)
            .environmentObject(states.companiesState)
        }
        .commands {
            SidebarCommands()
        }

        #if os(macOS)
        Settings {
            VStack{
                Text("Settings view")
            }
            .frame(width: 500, height: 500)
        }
        #endif
    }

}
