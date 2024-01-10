//
//  NoProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewProjectSheet: View {

    @EnvironmentObject private var projectsState: ProjectsState

    
    var body: some View {
        NavigationView {
            NewProjectView { name in
                projectsState.createProject(named: name) { f in

                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.projectsState.dismissNewProject()
                    }
                }
            }
        }

    }

}
