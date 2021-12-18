//
//  Invoices_iOSApp.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 10.12.2021.
//

import SwiftUI

@main
struct Invoices_iOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: ContentStore())
        }
    }
}
