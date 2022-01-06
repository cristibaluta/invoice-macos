//
//  CompanyDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.10.2021.
//

import SwiftUI

struct CompanyDetailsView: View {
    
    @ObservedObject var store: CompanyDetailsStore
    private var completion: (CompanyDetails) -> Void
    
    init (store: CompanyDetailsStore, completion: @escaping (CompanyDetails) -> Void) {
        self.store = store
        self.completion = completion
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                HStack {
                    Text("Nume*:").font(.system(size: 12))
                    TextField("", text: $store.name).font(.system(size: 12)).onChange(of: store.name) { _ in
                        completion(store.data)
                    }
                }
                HStack {
                    Text("Nr.ORC/an*:").font(.system(size: 12))
                    TextField("", text: $store.orc).font(.system(size: 12)).onChange(of: store.orc) { _ in
                        completion(store.data)
                    }
                }
                HStack {
                    Text("C.U.I.*:").font(.system(size: 12))
                    TextField("", text: $store.cui).font(.system(size: 12)).onChange(of: store.cui) { _ in
                        completion(store.data)
                    }
                }
                HStack {
                    Text("Sediul*:").font(.system(size: 12))
                    TextField("", text: $store.address).font(.system(size: 12)).onChange(of: store.address) { _ in
                        completion(store.data)
                    }
                }
                HStack {
                    Text("Județul*:").font(.system(size: 12))
                    TextField("", text: $store.county).font(.system(size: 12)).onChange(of: store.county) { _ in
                        completion(store.data)
                    }
                }
                HStack {
                    Text("Contul*:").font(.system(size: 12))
                    TextField("", text: $store.bankAccount).font(.system(size: 12)).onChange(of: store.bankAccount) { _ in
                        completion(store.data)
                    }
                }
                HStack {
                    Text("Banca*:").font(.system(size: 12))
                    TextField("", text: $store.bankName).font(.system(size: 12)).onChange(of: store.bankName) { _ in
                        completion(store.data)
                    }
                }
            }
            
            Divider()
            
            Group {
                HStack(alignment: .center) {
                    Text("Email:").font(.system(size: 12))
                    TextField("", text: $store.email).onChange(of: store.email) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Phone:").font(.system(size: 12))
                    TextField("", text: $store.phone).onChange(of: store.phone) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
                HStack(alignment: .center) {
                    Text("Website:").font(.system(size: 12))
                    TextField("", text: $store.web).onChange(of: store.web) { _ in
                        completion(store.data)
                    }.font(.system(size: 12))
                }
            }
        }
    }
}
