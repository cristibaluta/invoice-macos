//
//  NoProjectsScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 18.07.2022.
//

import SwiftUI

struct NoFolderScreen: View {

    @EnvironmentObject private var foldersState: FoldersState


    var body: some View {
        NewFolderView { name in
            foldersState.createFolder(named: name) { f in
                
            }
        }
    }

}
