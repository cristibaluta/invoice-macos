//
//  ProjectsMenu.swift
//  Invoices
//
//  Created by Cristian Baluta on 13.01.2024.
//

import Foundation
import SwiftUI

struct ProjectsMenu: View {

    @EnvironmentObject var mainWindowState: MainWindowState
    @ObservedObject var projectsStore: ProjectsStore

    var body: some View {

        Text("Projects").bold()
        Menu {
            ForEach(projectsStore.projects) { project in
                Button(project.name, action: {
                    projectsStore.selectedProject = project
                    projectsStore.objectWillChange.send()
                })
            }
            Divider().frame(height: 1)
            Button("+ New project", action: {
                mainWindowState.contentType = .noProjects
            })
        } label: {
            Text(projectsStore.selectedProject?.name ?? "Select project")
        }
    }

}
