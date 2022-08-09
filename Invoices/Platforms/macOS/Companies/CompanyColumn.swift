//
//  CompanyColumn.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.08.2022.
//

import Foundation
import SwiftUI

struct CompanyColumn: View {

    @EnvironmentObject var companiesState: CompaniesState
    var data: CompanyData

    var body: some View {
        let _ = Self._printChanges()
        VStack {
            CompanyView(data: data) { data in
                print("onChange \(data.name)")
                companiesState.selectedCompany = data
            }
            .frame(width: 400)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Save") {
                    companiesState.saveSelectedCompany()
                }
            }
        }

    }

}
