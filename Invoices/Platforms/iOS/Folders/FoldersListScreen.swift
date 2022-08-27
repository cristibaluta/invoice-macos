//
//  ProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct FoldersListScreen: View {

    @EnvironmentObject var foldersState: FoldersState

    
    var body: some View {

        let _ = Self._printChanges()

        List {
            ForEach(foldersState.folders, id: \.self) { f in
                NavigationLink(destination: InvoicesListScreen(folder: f)) {
                    Label(f.name, systemImage: "list.bullet")
                }
            }
            .onDelete(perform: delete)
        }
        .refreshable {
            foldersState.refresh()
        }
        .onAppear {
            foldersState.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Projects").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New") {
                    foldersState.isShowingNewFolderSheet = true
                }
                .sheet(isPresented: $foldersState.isShowingNewFolderSheet) {
                    NewProjectSheet()
                }
            }
        }
        
    }

    private func delete(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        foldersState.deleteFolder(at: index)
    }
}
