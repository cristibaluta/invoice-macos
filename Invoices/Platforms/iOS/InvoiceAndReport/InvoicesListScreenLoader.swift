//
//  InvoicesListScreenLoader.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 21.02.2024.
//

import Foundation
import SwiftUI

struct InvoicesListScreenLoader: View {

    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var store: MainStore
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
        .onChange(of: isPresented) { oldValue in
            print("InvoicesListScreenLoader is isPresented \(isPresented) oldValue \(oldValue)")
            if !isPresented {
                store.projectsStore.selectedProject = nil
            }
        }
    }

}
