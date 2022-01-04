//
//  NewInvoiceView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewInvoiceView: View {
    
    @ObservedObject var store: InvoiceStore
    var callback: () -> Void
    
    init (store: InvoiceStore, callback: @escaping () -> Void) {
        self.store = store
        self.callback = callback
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            Text("New invoice!").font(.system(size: 40)).bold()
            
            Divider().frame(height: 200)
            
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                Text("\(store.editingStore.invoiceSeries)-\(store.editingStore.invoiceNr)")
                    .font(.system(size: 20)).bold()
                Text(store.editingStore.date.mediumDate)
                .font(.system(size: 20))
                
                HStack(alignment: .center) {
                    Text("Exchange rate:").font(.system(size: 20))
                    TextField("", text: $store.editingStore.exchangeRate).font(.system(size: 20)).frame(width: 100)
                }
                HStack(alignment: .center) {
                    Text("Units(\(store.editingStore.unitsName)):").font(.system(size: 20))
                    TextField("", text: $store.editingStore.units).font(.system(size: 20)).frame(width: 100)
                }
                Spacer().frame(height: 30)
                
                Button("Create") {
                    store.data = store.editingStore.data
                    store.calculate()
                    store.save() { _ in
                        callback()
                    }
                }
            }
            Spacer()
        }
    }
}
