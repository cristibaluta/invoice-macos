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
                Text("\(store.editingStore.invoiceSeries)-\(store.editingStore.invoiceNr)")
                .font(.system(size: 20))
                Text(store.editingStore.date.mediumDate)
                .font(.system(size: 20))
                HStack(alignment: .center) {
                    Text("Exchange rate:").font(.system(size: 20))
                    TextField("", text: $store.editingStore.exchangeRate).onChange(of: store.editingStore.exchangeRate) { _ in
//                        completion(store.data)
                    }
                    .font(.system(size: 20)).frame(width: 100)
                }
                HStack(alignment: .center) {
                    Text("Units(\(store.editingStore.unitsName)):").font(.system(size: 20))
                    TextField("", text: $store.editingStore.units).onChange(of: store.editingStore.units) { _ in
//                        completion(store.data)
                    }
                    .font(.system(size: 20)).frame(width: 100)
                }
                Spacer().frame(height: 30)
                Button("Create") {
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
