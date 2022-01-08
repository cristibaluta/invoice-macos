//
//  NoProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NoProjectsView: View {
#if os(iOS)
    typealias Stack = VStack
#else
    typealias Stack = HStack
#endif
    @ObservedObject var store: WindowStore
    var completion: (() -> Void)?
    
    init (store: WindowStore, completion: @escaping () -> Void) {
        self.store = store
        self.completion = completion
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("New project").font(.system(size: 40)).bold().padding(10)
            Text("In a project you can keep invoices from the same series.")
                .multilineTextAlignment(.center)
            Spacer()
            Stack {
                TextField("Project name", text: $store.projectName).frame(width: 160).multilineTextAlignment(.center)
                Button("Create") {
                    store.createProject(store.projectName)
                    completion?()
                }
            }
            Spacer()
            Spacer()
        }
    }
}
