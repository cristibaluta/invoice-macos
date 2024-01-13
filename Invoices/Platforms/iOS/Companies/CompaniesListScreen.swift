//
//  CompaniesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.01.2022.
//

import SwiftUI

struct CompaniesListScreen: View {

    @EnvironmentObject var companiesData: CompaniesStore


    var body: some View {

        List(companiesData.companies, id: \.self, selection: $companiesData.selectedCompany) { comp in
            NavigationLink(destination: CompanyScreen(data: comp.data)) {
                Label(comp.name, systemImage: "list.bullet")
            }
        }
        .refreshable {
            companiesData.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Companies").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    companiesData.selectedCompany = CompaniesInteractor.emptyCompanyDetails
                    companiesData.isShowingNewCompanySheet = true
                }
                .sheet(isPresented: $companiesData.isShowingNewCompanySheet) {
                    NewCompanySheet()
                }
            }
        }
        .onAppear {
            companiesData.refresh()
        }
    }
    
}
