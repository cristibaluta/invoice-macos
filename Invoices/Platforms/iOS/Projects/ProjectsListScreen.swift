//
//  ProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct ProjectsListScreen: View {

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var store: MainStore

    var body: some View {

        let _ = Self._printChanges()

        List {
            ForEach(store.projectsStore.projects, id: \.self) { proj in
                NavigationLink(proj.name, value: proj)
            }
            .onDelete(perform: delete)
        }
        .navigationDestination(for: Project.self) { proj in
            if let invoicesStore = store.projectsStore.invoicesStore {
                InvoicesListScreen(invoicesStore: invoicesStore)
                    .navigationBarTitle(proj.name, displayMode: .inline)
                    .onDisappear {
                        store.projectsStore.dismissSelectedProject()
                    }
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarItems(leading: Button(action : {
////                        store.projectsStore.dismissSelectedProject()
//                        self.mode.wrappedValue.dismiss()
//                    }){
//                        Image(systemName: "arrow.left")
//                    })
            } else {
                Text("Loading...")
                    .task {
                        store.projectsStore.selectedProject = proj
                    }
            }
        }
        .refreshable {
            store.projectsStore.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New") {
                    store.projectsStore.isShowingNewProjectSheet = true
                    store.objectWillChange.send()
                }
                .sheet(isPresented: $store.projectsStore.isShowingNewProjectSheet) {
                    NewProjectSheet()
                }
            }
        }
        .navigationBarTitle("Projects", displayMode: .inline)

    }

    private func delete (at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        store.projectsStore.deleteProject(at: index)
    }
}
