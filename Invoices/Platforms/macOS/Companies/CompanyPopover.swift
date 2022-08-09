//
//  CompanyPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 23.07.2022.
//

import SwiftUI

struct CompanyPopover: View {

    @EnvironmentObject var companiesState: CompaniesState
    var data: CompanyData
//    init() {
//        print("init CompanyPopover")
//    }

    var body: some View {
        let _ = Self._printChanges()
        VStack {
            CompanyView(data: data) { data in
                print("onChange \(data.name)")
                companiesState.selectedCompany = data
            }
            .padding()
            Spacer()
            Button("Save") {
                companiesState.saveSelectedCompany()
            }
            .padding()
        }

    }
}
