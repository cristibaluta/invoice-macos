//
//  InvoicesListScreenLoader.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 21.02.2024.
//

import Foundation
import SwiftUI

struct InvoicesListScreenLoader: View {

    @EnvironmentObject var store: MainStore
    @ObservedObject var invoicesStore: InvoicesStore
    var project: Project
    

    var body: some View {
        VStack{
            if let invoicesStore = store.projectsStore.invoicesStore {
                InvoicesListScreen(invoicesStore: invoicesStore)
                    .navigationBarTitle(project.name, displayMode: .inline)
            } else {
                Text("Loading...")
                    .task {
                        store.projectsStore.selectedProject = project
                    }
            }
        }
    }

}
