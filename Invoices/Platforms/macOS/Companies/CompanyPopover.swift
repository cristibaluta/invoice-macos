//
//  CompanyPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 23.07.2022.
//

import SwiftUI

struct CompanyPopover: View {

    @EnvironmentObject var companiesData: CompaniesData
    var data: CompanyData
//    init() {
//        print("init CompanyPopover")
//    }

    var body: some View {
        let _ = Self._printChanges()
        VStack {
            CompanyView(data: data) { data in
                print("onChange \(data.name)")
                companiesData.selectedCompany = data
            }
            .padding()
            Spacer()
            Button("Save") {
                companiesData.saveSelectedCompany()
            }
            .padding()
        }

    }
}
