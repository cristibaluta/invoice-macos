//
//  NoProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewProjectSheet: View {

    @EnvironmentObject var store: MainStore

    
    var body: some View {
        NavigationView {
            NewProjectView { name in
                store.projectsStore.createProject(named: name)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.projectsStore.dismissNewProject()
                    }
                }
            }
        }

    }

}
