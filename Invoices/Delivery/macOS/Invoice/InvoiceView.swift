//
//  InvoiceView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.11.2021.
//

import SwiftUI

struct InvoiceView: View {
    
    @ObservedObject var store: InvoiceStore
    
    @State var showingPopover = false
    @State var showingClient = false
    
    init (store: InvoiceStore) {
        self.store = store
        print("New invoiceview \(store.data.invoice_nr)")
    }
    
    var body: some View {
        HStack {
            Spacer()
            HtmlView(htmlString: store.html) { printingData in
                store.invoicePrintData = printingData
            }
            .frame(width: 920)
            .padding(10)
            Spacer()
            Divider().padding(.top, 10).padding(.bottom, 10)
            InvoiceEditingView(store: store.editingStore) { data in
                store.data = data
                store.calculate()
            }
            .frame(width: 220, alignment: .trailing)
        }
    }
}
