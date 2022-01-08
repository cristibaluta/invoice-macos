//
//  ProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct ProjectsView: View {
    
    @ObservedObject var store: WindowStore
    @State var selection: Int?
    
    init (store: WindowStore) {
        self.store = store
    }
    
    var body: some View {
        List(store.projects, id: \.self, selection: $store.selectedInvoice) { project in
            NavigationLink(
                destination: InvoicesView(store: store, project: project),
                tag: 0,
                selection: $selection
            ) {
                Label(project.name, systemImage: "list.bullet")
            }
            .tag(0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Projects").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(
                    destination: NoProjectsView(store: store) { store.reloadProjects() },
                    tag: 1,
                    selection: $selection
                ) {
                    Text("Add")
                }
            }
        }
    }
}
