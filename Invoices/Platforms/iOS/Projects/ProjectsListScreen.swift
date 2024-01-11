//
//  ProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct ProjectsListScreen: View {

    @EnvironmentObject var projectsData: ProjectsData

    
    var body: some View {

        let _ = Self._printChanges()

        List {
            ForEach(projectsData.projects, id: \.self) { f in
                NavigationLink(destination: InvoicesListScreen(folder: f)) {
                    Label(f.name, systemImage: "list.bullet")
                }
            }
            .onDelete(perform: delete)
        }
        .refreshable {
            projectsData.refresh()
        }
        .onAppear {
            projectsData.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Projects").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New") {
                    projectsData.isShowingNewProjectSheet = true
                }
                .sheet(isPresented: $projectsData.isShowingNewProjectSheet) {
                    NewProjectSheet()
                }
            }
        }
        
    }

    private func delete(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        projectsData.deleteProject(at: index)
    }
}
