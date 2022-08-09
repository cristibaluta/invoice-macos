//
//  ProjectsListView.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.07.2022.
//

import SwiftUI

struct ProjectsListView: View {

    @EnvironmentObject var projectsState: ProjectsState

    var body: some View {
        List(projectsState.projects, id: \.self, selection: $projectsState.selectedProject) { proj in
            NavigationLink(destination: InvoicesListScreen(project: proj)) {
                Label(proj.name, systemImage: "list.bullet")
            }
        }
        .refreshable {
            projectsState.refresh()
        }
        .onAppear {
            projectsState.refresh()
        }
    }

}
