//
//  NoProjectsScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 18.07.2022.
//

import SwiftUI

struct NoProjectsScreen: View {

    @EnvironmentObject private var projectsData: ProjectsData


    var body: some View {
        NewProjectView { name in
            projectsData.createProject(named: name) { _ in
                
            }
        }
    }

}
