//
//  NoCompaniesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2022.
//

import SwiftUI

struct NoCompaniesView: View {

#if os(iOS)
    typealias Stack = VStack
#else
    typealias Stack = HStack
#endif

    var callback: () -> Void

    init (callback: @escaping () -> Void) {
        self.callback = callback
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Text("No companies").font(.system(size: 40)).bold().padding(10)
            Text("Add here your company and your clients, then you can use them in invoices")
                .multilineTextAlignment(.center)

            Spacer()

            Button("Add new") {
                callback()
            }

            Spacer()
            Spacer()
        }
    }
}
