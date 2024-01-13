//
//  NewProjectView.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.07.2022.
//

import Foundation
import SwiftUI

struct NewProjectView: View {

#if os(iOS)
    typealias Stack = VStack
#else
    typealias Stack = VStack
#endif

    @State var projectName: String = ""
    private var onTap: (String) -> Void

    init (onTap: @escaping (String) -> Void) {
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .center) {

            Text("New project").font(.system(size: 40)).bold().padding(10)
            Text("In a project you can keep invoices from the same series.")
                .multilineTextAlignment(.center)

            Spacer().frame(height: 60)

            Stack {
                TextField("Project name", text: $projectName)
                    .frame(width: 160)
                    .multilineTextAlignment(.center)
                    .modifier(OutlineTextField())

                Spacer().frame(height: 20)

                Button("Create") {
                    onTap(projectName)
                }
            }
        }
    }

}
