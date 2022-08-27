//
//  WindowView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.01.2022.
//

import Foundation
import SwiftUI

struct MainView: View {

    @EnvironmentObject var foldersState: FoldersState
    @EnvironmentObject var invoicesState: InvoicesState
    @EnvironmentObject var companiesState: CompaniesState
    private let contentColumnState = ContentColumnState()
    
    var body: some View {

        let _ = Self._printChanges()

        content
        .frame(minWidth: 1000, idealWidth: 1200, minHeight: 600, idealHeight: 900, alignment: .topLeading)
        .onAppear {
            foldersState.refresh()
            companiesState.refresh()
        }
    }

    var content: some View {
        NavigationView {
            if !foldersState.folders.isEmpty {
                SidebarColumn()
                .environmentObject(contentColumnState)
                .frame(minWidth: 180)
            }

            ContentColumn()
            .environmentObject(contentColumnState)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
        .navigationViewStyle(.columns)
//        .navigationTitle(state.invoiceName)
        
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
