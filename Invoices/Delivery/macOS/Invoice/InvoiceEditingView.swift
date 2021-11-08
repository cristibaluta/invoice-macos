//
//  InvoiceDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI

struct InvoiceEditingView: View {
    
    @ObservedObject var store: InvoiceEditingStore
    private var completion: (InvoiceData) -> Void
    @State var showingFurnizor = false
    @State var showingClient = false
    
    init (store: InvoiceEditingStore, completion: @escaping (InvoiceData) -> Void) {
        self.store = store
        self.completion = completion
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                HStack(alignment: .center) {
                    Text("Invoice date:").font(.system(size: 12))
                    DatePicker("", selection: $store.date, displayedComponents: .date)
                        .onChange(of: store.date) { _ in
                            completion(store.data)
                        }
                        .font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Product:").font(.system(size: 12))
                    TextField("", text: $store.productName).onChange(of: store.productName) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Rate:").font(.system(size: 12))
                    TextField("", text: $store.rate).onChange(of: store.rate) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Exchange Rate:").font(.system(size: 12))
                    TextField("", text: $store.exchangeRate).onChange(of: store.exchangeRate) { _ in
                        completion(store.data)
                    }
                    .font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Units:").font(.system(size: 12))
                    TextField("", text: $store.units).onChange(of: store.units) { _ in
                        completion(store.data)
                    }
                    .font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Units name:").font(.system(size: 12))
                    TextField("", text: $store.unitsName).onChange(of: store.unitsName) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("TVA:").font(.system(size: 12))
                    TextField("TVA", text: $store.tva).onChange(of: store.tva) { _ in
                        completion(store.data)
                    }
                    .font(.system(size: 12))
                }
            }
            
            Divider().padding(.top, 10).padding(.bottom, 10)
            
            Group {
                
                HStack(alignment: .center) {
                    Text("Invoice series:").font(.system(size: 12))
                    TextField("", text: $store.invoiceSeries).onChange(of: store.invoiceSeries) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Invoice nr:").font(.system(size: 12))
                    TextField("", text: $store.invoiceNr).onChange(of: store.invoiceNr) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
            }
            
            Divider().padding(.top, 10).padding(.bottom, 10)

            Button("My company") {
                showingFurnizor.toggle()
                showingClient = false
            }
            if showingFurnizor {
                Divider()
                CompanyDetailsView(store: CompanyDetailsStore(data: store.data.contractor)) { companyData in
                    store.data.contractor = companyData
                    completion(store.data)
                }
                Divider()
            }
            
            Button("Client") {
                showingClient.toggle()
                showingFurnizor = false
            }
            if showingClient {
                Divider()
                CompanyDetailsView(store: CompanyDetailsStore(data: store.data.client)) { companyData in
                    store.data.client = companyData
                    completion(store.data)
                }
                Divider()
            }
            Spacer()
        }
        .padding(10)
    }
}
