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
            HStack {
                Text("Nume:").font(.system(size: 12))
                TextField("", text: $store.name).font(.system(size: 12)).onChange(of: store.name) { _ in
                    completion(store.data)
                }
            }
            HStack {
                Text("Nr.ORC/an:").font(.system(size: 12))
                TextField("", text: $store.orc).font(.system(size: 12))
            }
            HStack {
                Text("C.U.I.:").font(.system(size: 12))
                TextField("", text: $store.cui).font(.system(size: 12))
            }
            HStack {
                Text("Sediul:").font(.system(size: 12))
                TextField("", text: $store.address).font(.system(size: 12))
            }
            HStack {
                Text("Județul:").font(.system(size: 12))
                TextField("", text: $store.county).font(.system(size: 12))
            }
            HStack {
                Text("Contul:").font(.system(size: 12))
                TextField("", text: $store.bankAccount).font(.system(size: 12))
            }
            HStack {
                Text("Banca:").font(.system(size: 12))
                TextField("", text: $store.bankName).font(.system(size: 12))
            }
        }
    }
}
