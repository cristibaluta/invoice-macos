//
//  NewCompanyView.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import SwiftUI

struct NewCompanyView: View {
    
    @ObservedObject var store: CompaniesStore
    var callback: () -> Void
    var company: CompanyData?
    
    init (store: CompaniesStore, company: CompanyData?, callback: @escaping () -> Void) {
        self.store = store
        self.company = company
        self.callback = callback
    }
    
    #if os(macOS)
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            
            Text("New company").font(.system(size: 40)).bold()
            
            Divider().frame(height: 360)
            
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                CompanyDetailsView(store: store.companyDetailsStore) { companyData in
//                    store.data = companyData
                }
                
                Spacer().frame(height: 30)
                
                HStack(alignment: .center) {
                    Button("Cancel") {
                        callback()
                    }
                    Button("Save") {
                        store.companyDetailsStore.save() {
                            callback()
                        }
                    }
                }
            }
            .frame(width: 400)
            
            Spacer()
        }
    }
    #else
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        CompanyDetailsView(store: store.companyDetailsStore) { companyData in
//            store.data = companyData
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(company?.name ?? "New company").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    store.companyDetailsStore.save() {
                        callback()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: { Image(systemName: "arrow.left") }))
        .onAppear {
            self.store.selectedCompany = company
        }
    }
    #endif
}
