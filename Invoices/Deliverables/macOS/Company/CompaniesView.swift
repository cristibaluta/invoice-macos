//
//  CompaniesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.01.2022.
//

import SwiftUI

struct CompaniesView: View {
    
    @ObservedObject var store: CompaniesStore
    @State var selection: Int?
    
    init (store: CompaniesStore) {
        self.store = store
    }
    
    var body: some View {
        List(store.companies, id: \.self, selection: $store.selectedCompany) { company in
            NavigationLink(
                destination: NewCompanyView(store: store, company: company) { store.reload() },
                tag: 0,
                selection: $selection
            ) {
                Text(company.name)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Companies").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(
                    destination: NewCompanyView(store: store, company: nil) { store.reload() },
                    tag: 1,
                    selection: $selection
                ) {
                    Text("Add")
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
