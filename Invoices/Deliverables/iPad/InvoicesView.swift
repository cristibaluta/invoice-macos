//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesView: View {
    
    @ObservedObject var store: WindowStore
    @State var selection: Int?
    private var project: Project
    
    init (store: WindowStore, project: Project) {
        self.store = store
        self.project = project
    }
    
    var body: some View {
        List(store.invoices, id: \.self, selection: $store.selectedInvoice) { invoice in
            NavigationLink(
              destination: Spacer(),
              tag: 0,
              selection: $selection
            ) {
                Label(invoice.name, systemImage: "doc.text")
            }
            .tag(0)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Invoices").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    
                }
            }
        }
        .onAppear {
            store.loadProject(project)
        }
    }
}
