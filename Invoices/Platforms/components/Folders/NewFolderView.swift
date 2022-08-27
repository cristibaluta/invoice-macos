//
//  NewProjectView.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.07.2022.
//

import Foundation
import SwiftUI

struct NewFolderView: View {

#if os(iOS)
    typealias Stack = VStack
#else
    typealias Stack = VStack
#endif

    @State var folderName: String = ""
    private var onTap: (String) -> Void

    init (onTap: @escaping (String) -> Void) {
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .center) {

            Text("New folder").font(.system(size: 40)).bold().padding(10)
            Text("In a folder you can keep invoices from the same series.")
                .multilineTextAlignment(.center)

            Spacer().frame(height: 60)

            Stack {
                TextField("Folder name", text: $folderName)
                    .frame(width: 160)
                    .multilineTextAlignment(.center)
                    .modifier(OutlineTextField())

                Spacer().frame(height: 20)

                Button("Create") {
                    onTap(folderName)
                }
            }
        }
    }
}
