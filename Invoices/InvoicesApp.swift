//
//  InvoicesApp.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI

@main
struct InvoicesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: ContentStore())
        }
    }
}
