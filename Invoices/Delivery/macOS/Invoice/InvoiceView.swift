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
    
    private var completion: (InvoiceData) -> Void
    
    init (store: InvoiceStore, completion: @escaping (InvoiceData) -> Void) {
        self.store = store
        self.completion = completion
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
                completion(data)
            }
            .frame(width: 220, alignment: .trailing)
        }
    }
}
