//
//  InvoiceDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI

struct InvoiceEditingView: View {
    
    @ObservedObject var store: InvoiceEditingStore
    @State var isAddingNewClient = false
    @State var isAddingNewContractor = false
    private var completion: (InvoiceData) -> Void
    
    init (store: InvoiceEditingStore, completion: @escaping (InvoiceData) -> Void) {
        self.store = store
        self.completion = completion
    }
    
    var body: some View {
        ScrollView(.vertical) {
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
                        Text("Product(1):").font(.system(size: 12))
                        TextField("", text: $store.productName).onChange(of: store.productName) { _ in
                            completion(store.data)
                        }.font(.system(size: 12))
                    }
                    HStack(alignment: .center) {
                        Text("Rate(2):").font(.system(size: 12))
                        TextField("", text: $store.rate).onChange(of: store.rate) { _ in
                            completion(store.data)
                        }.font(.system(size: 12))
                    }
                    HStack(alignment: .center) {
                        Text("Exchange Rate(3):").font(.system(size: 12))
                        TextField("", text: $store.exchangeRate).onChange(of: store.exchangeRate) { _ in
                            completion(store.data)
                        }
                        .font(.system(size: 12))
                    }
                    HStack(alignment: .center) {
                        Text("Units name(4):").font(.system(size: 12))
                        TextField("", text: $store.unitsName).onChange(of: store.unitsName) { _ in
                            completion(store.data)
                        }.font(.system(size: 12))
                    }
                    HStack(alignment: .center) {
                        Text("Units(5):").font(.system(size: 12))
                        if !store.isFixedTotal {
                            TextField("", text: $store.units).onChange(of: store.units) { _ in
                                completion(store.data)
                            }.font(.system(size: 12))
                        } else {
                            Text(store.units).font(.system(size: 12))
                        }
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
                    HStack(alignment: .center) {
                        Text("Contractor:").font(.system(size: 12))
                        Menu {
                            ForEach(store.companies) { company in
                                Button(company.name, action: {
                                    store.contractorData = company.details
                                    completion(store.data)
                                })
                            }
                            Divider()
                            Button("Add new", action: {
                                isAddingNewContractor = true
                            })
                        } label: {
                            Text(store.contractorData.name)
                        }
                    }
                    .popover(isPresented: $isAddingNewContractor) {
                        VStack(alignment: .leading) {
                            CompanyDetailsView(store: store.contractorDetailsStore) { company in
                                store.contractorData = company
                            }
                            .padding(20)
                            HStack {
                                Button("Cancel", action: {
                                    isAddingNewContractor = false
                                })
                                Button("Save", action: {
                                    store.contractorDetailsStore.save() {
                                        isAddingNewContractor = false
                                        store.reloadCompanies()
                                        store.contractorData = store.contractorDetailsStore.data
                                        completion(store.data)
                                    }
                                })
                            }
                            .padding(20)
                        }
                        .frame(width: 400)
                    }
                    
                    HStack(alignment: .center) {
                        Text("Client:").font(.system(size: 12))
                        Menu {
                            ForEach(store.companies) { company in
                                Button(company.name, action: {
                                    store.clientData = company.details
                                    completion(store.data)
                                })
                            }
                            Divider()
                            Button("Add new", action: {
                                isAddingNewClient = true
                            })
                        } label: {
                            Text(store.clientData.name)
                        }
                    }
                    .popover(isPresented: $isAddingNewClient) {
                        VStack(alignment: .leading) {
                            CompanyDetailsView(store: store.clientDetailsStore) { company in
                                store.clientData = company
                            }
                            .padding(20)
                            HStack {
                                Button("Cancel", action: {
                                    isAddingNewClient = false
                                })
                                Button("Save", action: {
                                    store.clientDetailsStore.save() {
                                        isAddingNewClient = false
                                        store.reloadCompanies()
                                        store.clientData = store.clientDetailsStore.data
                                        completion(store.data)
                                    }
                                })
                            }
                            .padding(20)
                        }
                        .frame(width: 400)
                    }
                    Spacer()
                }
            }
            .padding(10)
        }
    }
}
