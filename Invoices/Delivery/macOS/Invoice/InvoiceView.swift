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
    }
    
    var body: some View {
        VStack {
            HtmlView(htmlString: store.html) { printingData in
                store.invoicePrintData = printingData
            }
            .padding(10)
        }
    }
}
