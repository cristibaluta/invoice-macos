//
//  WindowView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.01.2022.
//

import Foundation
import SwiftUI

struct MainWindow: View {

    @EnvironmentObject var store: MainStore
    @EnvironmentObject var companiesStore: CompaniesStore

    private let mainWindowState = MainWindowState()

    var body: some View {

        let _ = Self._printChanges()

        content
        .frame(minWidth: 1000, idealWidth: 1200, minHeight: 600, idealHeight: 900, alignment: .topLeading)
        .onAppear {
            // Refresh the projects
            store.projectsStore.refresh()
            store.projectsStore.selectLastProject()
            // Refresh the companies
            companiesStore.refresh()
        }
    }

    var content: some View {
        NavigationView {
            if !store.projectsStore.projects.isEmpty {
                SidebarColumn()
                .frame(minWidth: 180)
            }

            ContentColumn()
            .frame(minWidth: 900)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
        .navigationViewStyle(.columns)
        .environmentObject(mainWindowState)
//        .navigationTitle(state.invoiceName)
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
