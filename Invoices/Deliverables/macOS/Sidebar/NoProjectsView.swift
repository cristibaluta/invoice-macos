//
//  NoProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NoProjectsView: View {
    
    @ObservedObject var store: ContentStore
    
    init (store: ContentStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("New project").font(.system(size: 40)).bold().padding(10)
            Text("In a project you can keep invoices from the same series.")
                .multilineTextAlignment(.center)
            Spacer()
            HStack {
                TextField("Project name", text: $store.projectName).frame(width: 160)
                Button("Create") {
//                    store.createProject(store.projectName)
                }
            }
            Spacer()
            Spacer()
        }
    }
}
