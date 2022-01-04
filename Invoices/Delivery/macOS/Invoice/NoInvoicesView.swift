//
//  NoInvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NoInvoicesView: View {
    
    @ObservedObject var store: ContentStore
    
    init (store: ContentStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Create your first invoice!").font(.system(size: 40)).bold().padding(20)
            Text("Each project has its own templates and can be edited from Finder. You can right click on any invoice to view the files in Finder.")
                .multilineTextAlignment(.center).padding(20)
            Button("New invoice") {
                store.generateNewInvoice()
            }
        }
    }
}
