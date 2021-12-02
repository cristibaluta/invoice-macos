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
    @State var showingContractor = false
    @State var showingClient = false
    
    init (store: InvoiceEditingStore, completion: @escaping (InvoiceData) -> Void) {
        self.store = store
        self.completion = completion
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
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
                HStack(alignment: .center) {
                    Text("Invoice date:").font(.system(size: 12))
                    DatePicker("", selection: $store.date, displayedComponents: .date)
                        .onChange(of: store.date) { _ in
                            completion(store.data)
                        }
                        .font(.system(size: 12))
                }
            }
            
            Divider().padding(.top, 10).padding(.bottom, 10)

            Group {
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
                    if !store.isFixedTotal {
                        TextField("", text: $store.units).onChange(of: store.units) { _ in
                            completion(store.data)
                        }.font(.system(size: 12))
                    } else {
                        Text(store.units).font(.system(size: 12))
                    }
                    
                }
                HStack(alignment: .center) {
                    Text("Units name:").font(.system(size: 12))
                    TextField("", text: $store.unitsName).onChange(of: store.unitsName) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("VAT:").font(.system(size: 12))
                    TextField("VAT", text: $store.vat).onChange(of: store.vat) { _ in
                        completion(store.data)
                    }
                    .font(.system(size: 12))
                }
            }
            
            Divider().padding(.top, 10).padding(.bottom, 10)
            
            Group {
                Toggle("Fixed total", isOn: $store.isFixedTotal)
                Text("Will trigger the units to be calculated").font(.system(size: 10))
                if store.isFixedTotal {
                    HStack(alignment: .center) {
                        Text("Total amount VAT:").font(.system(size: 12))
                        TextField("Total", text: $store.amountTotalVat).onChange(of: store.amountTotalVat) { _ in
                            completion(store.data)
                        }
                        .font(.system(size: 12))
                    }
                } else {
                    Text("Total amount VAT: \(store.amountTotalVat)").font(.system(size: 12))
                }
            }
            
            Divider().padding(.top, 10).padding(.bottom, 10)
            
            Group {
                Button("Contractor") {
                    showingContractor.toggle()
                    showingClient = false
                }
                if showingContractor {
                    CompanyDetailsView(store: CompanyDetailsStore(data: store.data.contractor)) { companyData in
                        store.data.contractor = companyData
                        completion(store.data)
                    }
                    Divider()
                }
                
                Button("Client") {
                    showingClient.toggle()
                    showingContractor = false
                }
                if showingClient {
                    CompanyDetailsView(store: CompanyDetailsStore(data: store.data.client)) { companyData in
                        store.data.client = companyData
                        completion(store.data)
                    }
                    Divider()
                }
                Spacer()
            }
        }
        .padding(10)
    }
}
