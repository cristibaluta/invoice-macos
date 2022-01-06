//
//  InvoicesApp.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI
import RCPreferences

enum UserPreferences: String, RCPreferencesProtocol {
    
    case lastProject = "lastProject"
    
    func defaultValue() -> Any {
        switch self {
            case .lastProject: return ""
        }
    }
}

@main
struct InvoicesApp: App {
    var body: some Scene {
        WindowGroup {
            WindowView(store: WindowStore())
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
