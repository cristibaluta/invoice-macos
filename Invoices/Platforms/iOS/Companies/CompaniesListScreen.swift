//
//  CompaniesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.01.2022.
//

import SwiftUI

struct CompaniesListScreen: View {

    @EnvironmentObject var companiesState: CompaniesState


    var body: some View {

        List(companiesState.companies, id: \.self, selection: $companiesState.selectedCompany) { comp in
            NavigationLink(destination: CompanyScreen(data: comp.data)) {
                Label(comp.name, systemImage: "list.bullet")
            }
        }
        .refreshable {
            companiesState.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Companies").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    companiesState.selectedCompany = CompaniesInteractor.emptyCompanyDetails
                    companiesState.isShowingNewCompanySheet = true
                }
                .sheet(isPresented: $companiesState.isShowingNewCompanySheet) {
                    NewCompanySheet()
                }
            }
        }
        .onAppear {
            companiesState.refresh()
        }
    }
    
}
