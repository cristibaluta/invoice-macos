//
//  NoProjectsScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 18.07.2022.
//

import SwiftUI

struct NoProjectsScreen: View {

    @EnvironmentObject private var projectsState: ProjectsState


    var body: some View {
        NewProjectView { newProjectName in
            projectsState.createProject(named: newProjectName) { proj in
                
            }
        }
    }

}
