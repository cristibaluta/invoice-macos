//
//  ProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct ProjectsListScreen: View {

    @EnvironmentObject var projectsState: ProjectsState

    
    var body: some View {

        let _ = Self._printChanges()

        List {
            ForEach(projectsState.projects, id: \.self) { f in
                NavigationLink(destination: InvoicesListScreen(folder: f)) {
                    Label(f.name, systemImage: "list.bullet")
                }
            }
            .onDelete(perform: delete)
        }
        .refreshable {
            projectsState.refresh()
        }
        .onAppear {
            projectsState.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Projects").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New") {
                    projectsState.isShowingNewProjectSheet = true
                }
                .sheet(isPresented: $projectsState.isShowingNewProjectSheet) {
                    NewProjectSheet()
                }
            }
        }
        
    }

    private func delete(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        projectsState.deleteProject(at: index)
    }
}
