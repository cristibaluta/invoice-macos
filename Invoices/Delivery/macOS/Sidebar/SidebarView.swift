//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct SidebarView: View {
    
    @ObservedObject var store: ContentStore
    @State private var showingAddPopover = false
    @State private var showingDeleteAlert = false
    
    init (store: ContentStore) {
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
            }
            
            List(self.store.invoices, id: \.self, selection: $store.selectedInvoice) { invoice in
                Text(invoice.name)
                .onTapGesture {
                    store.loadInvoice(invoice)
                }
                .contextMenu {
                    Button(action: {
                        store.showInFinder(invoice)
                    }) {
                        Text("Show in Finder")
                    }
                    Button(action: {
                        showingDeleteAlert = true
                        store.deleteInvoice(invoice)
                    }) {
                        Text("Delete")
                    }
                }
//                .alert(isPresented: $showingDeleteAlert) {
//                    Alert(title: Text("Delete invoice?"),
//                          message: Text("Delete invoice?"),
//                          dismissButton: .default(Text("Got it!")))
//                }
            }
        }
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
                            store.viewState = .noProjects
                        }
                        Button("New Invoice") {
                            showingAddPopover = false
//                            store.viewState = .newInvoice
                            store.generateNewInvoice()
                        }
                        Button("New company") {
                            showingAddPopover = false
                            store.viewState = .company(nil)
                        }
                    }.padding(20)
                }
            }
        }
    }
}
