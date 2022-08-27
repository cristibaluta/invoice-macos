//
//  NoInvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 20.07.2022.
//

import SwiftUI

struct NoInvoicesView: View {

    var callback: (() -> Void)

    var body: some View {
        VStack(alignment: .center) {

            Spacer()

            Text("Create your first invoice!")
                .font(.system(size: 40))
                .bold()
                .padding(20)

            Text("Each folder has its own templates that can be edited individually.")
                .multilineTextAlignment(.center)
                .padding(20)
            #if os(iOS)
            Spacer()
            #endif
            
            Button("New invoice") {
                callback()
            }
            
            #if os(iOS)
            Spacer()
            #endif
            Spacer()
        }
    }

}
