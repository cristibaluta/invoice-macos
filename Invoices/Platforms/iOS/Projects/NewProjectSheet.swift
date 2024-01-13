//
//  NoProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewProjectSheet: View {

    @EnvironmentObject private var projectsData: ProjectsStore

    
    var body: some View {
        NavigationView {
            NewProjectView { name in
                projectsData.createProject(named: name) { f in

                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.projectsData.dismissNewProject()
                    }
                }
            }
        }

    }

}
