//
//  NoProjectsScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 18.07.2022.
//

import SwiftUI

struct NoProjectsScreen: View {

    @EnvironmentObject var store: MainStore

    var body: some View {
        NewProjectView { name in
            store.projectsStore.createProject(named: name)
        }
    }

}
