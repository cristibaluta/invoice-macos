//
//  NoProjectsScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 18.07.2022.
//

import SwiftUI

struct NoProjectsScreen: View {

    @EnvironmentObject private var projectsStore: ProjectsStore


    var body: some View {
        NewProjectView { name in
            projectsStore.createProject(named: name) { _ in
//                self.projectsStore.selectedProject = proj
            }
        }
    }

}
