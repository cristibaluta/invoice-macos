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
    
    init (store: CompaniesStore, callback: @escaping () -> Void) {
        self.store = store
        self.callback = callback
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            
            Text("New company").font(.system(size: 40)).bold()
            
            Divider().frame(height: 360)
            
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                CompanyDetailsView(store: store.companyDetailsStore) { companyData in
                    store.data = companyData
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
}
