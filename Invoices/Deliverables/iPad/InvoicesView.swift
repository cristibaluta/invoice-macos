//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesView: View {
    
    @ObservedObject var store: ContentStore
    @State var selection: Int?
    
    init (store: ContentStore) {
        self.store = store
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
    }
}
