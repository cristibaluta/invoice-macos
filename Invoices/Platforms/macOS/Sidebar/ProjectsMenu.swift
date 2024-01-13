//
//  ProjectsMenu.swift
//  Invoices
//
//  Created by Cristian Baluta on 13.01.2024.
//

import Foundation
import SwiftUI

struct ProjectsMenu: View {

    @ObservedObject var projectsStore: ProjectsStore

    var body: some View {

        Text("Projects").bold().padding(.leading, 16)
        Menu {
            ForEach(projectsStore.projects) { project in
                Button(project.name, action: {
                    projectsStore.selectedProject = project
                })
            }
        } label: {
            Text(projectsStore.selectedProject?.name ?? "Select project")
        }
        .padding(16)
    }

}
