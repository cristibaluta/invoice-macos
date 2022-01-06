//
//  WindowView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.01.2022.
//

import Foundation
import SwiftUI

struct WindowView: View {
    
    @ObservedObject var store: WindowStore
    @State private var showingAddPopover = false
    @State private var showingDeleteAlert = false
    
    init (store: WindowStore) {
        self.store = store
    }
    
    var body: some View {
        NavigationView {
            switch store.sidebarState {
                case .noProjects:
                    Text("No projects!")
                    .frame(minWidth: 200)
                    
                case .projects(_), .invoices(_):
                    SidebarView(store: store)
                    .frame(minWidth: 200)
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            Spacer()
                            Button("+") {
                                showingAddPopover = true
                            }
                            .popover(isPresented: $showingAddPopover) {
                                VStack {
                                    Button("New Project") {
                                        showingAddPopover = false
                                        store.contentStore.viewState = .noProjects
                                    }
                                    Button("New Invoice") {
                                        showingAddPopover = false
                                        store.generateNewInvoice()
                                    }
                                    Button("New company") {
                                        showingAddPopover = false
                                        store.contentStore.viewState = .company(nil)
                                    }
                                }.padding(20)
                            }
                        }
                    }
            }
            
            #if os(macOS)
            ContentView(store: store.contentStore)
            #endif
        }
        .frame(maxWidth: .infinity, minHeight: 600, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle(store.invoiceName)
    }
}
