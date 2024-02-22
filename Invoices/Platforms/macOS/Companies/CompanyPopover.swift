//
//  CompanyPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 23.07.2022.
//

import SwiftUI

struct CompanyPopover: View {

    @EnvironmentObject var companiesStore: CompaniesStore
    var data: CompanyData

    var body: some View {

        let _ = Self._printChanges()
        
        VStack {
            CompanyView(data: data) { data in
                print("onChange \(data.name)")
                companiesStore.selectedCompany = data
            }
            .padding()
            Spacer()
            Button("Save") {
                companiesStore.saveSelectedCompany()
            }
            .padding()
        }

    }
}
