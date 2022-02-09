//
//  InvoiceView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 08.01.2022.
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
        ScrollView {
            VStack {
                InvoiceEditingView(store: store.editingStore) { data in
                    store.data = data
                    store.calculate()
                    completion(data)
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                HtmlView(htmlString: store.html) { printingData in
                    store.invoicePrintData = printingData
                }
                .frame(width: 920)
            }
        }
    }
}
