//
//  DeleteConfirmationView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.01.2022.
//

import SwiftUI

struct DeleteConfirmationView: View {
    
    @ObservedObject var store: ContentStore
    private var invoice: InvoiceFolder
    
    init (store: ContentStore, invoice: InvoiceFolder) {
        self.store = store
        self.invoice = invoice
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Delete invoice").font(.system(size: 40)).bold().padding(10)
            Text("Are you sure you want to delete invoice \(invoice.name)? This operation is irreversible.").multilineTextAlignment(.center)
            Spacer().frame(height: 20)
            HStack {
                Button("Cancel") {
                    store.showChart(nil, nil)
                }
                Button("Delete") {
                    store.deleteInvoice(invoice)
                }
            }
            Spacer()
        }
    }
}
