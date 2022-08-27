//
//  NoProjectsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewFolderSheet: View {

    @EnvironmentObject private var foldersState: FoldersState

    
    var body: some View {
        NavigationView {
            NewFolderView { name in
                foldersState.createFolder(named: name) { f in

                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.foldersState.dismissNewFolder()
                    }
                }
            }
        }

    }

}
