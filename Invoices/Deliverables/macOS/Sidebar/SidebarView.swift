//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct SidebarView: View {
    
    @ObservedObject var store: WindowStore
    
    init (store: WindowStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Menu {
                ForEach(store.projects) { project in
                    Button(project.name, action: {
                        store.loadProject(project)
                    })
                }
            } label: {
                Text(store.selectedProject?.name ?? "Project")
            }
            .padding(10)
            
            if self.store.invoices.isEmpty {
                Text("No invoices!")
            } else {
                List(self.store.invoices, id: \.self, selection: $store.selectedInvoice) { invoice in
                    Text(invoice.name)
                    .contextMenu {
                        Button(action: {
                            store.showInFinder(invoice)
                        }) {
                            Text("Show in Finder")
                        }
                        Button(action: {
                            store.contentStore.viewState = .deleteInvoice(invoice)
                        }) {
                            Text("Delete")
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
        }
    }
}
