//
//  NewCompanyView.swift
//  Invoices
//
//  Created by Cristian Baluta on 29.12.2021.
//

import SwiftUI

struct NewCompanySheet: View {

    @EnvironmentObject var companiesState: CompaniesState

    init() {
        print("init NewCompanySheet")
    }

    var body: some View {
        let _ = Self._printChanges()
        NavigationView {
            ScrollView {
                CompanyView(data: CompaniesInteractor.emptyCompanyDetails) { data in
                    print("onChange \(data.name)")
                    companiesState.selectedCompany = data
                }
                .padding()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.companiesState.dismissNewCompany()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("New company").font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        companiesState.saveSelectedCompany()
                    }
                }
            }

        }

    }
}
