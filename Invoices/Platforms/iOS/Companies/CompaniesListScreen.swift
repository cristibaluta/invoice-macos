//
//  CompaniesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.01.2022.
//

import SwiftUI

struct CompaniesListScreen: View {

    @EnvironmentObject var store: MainStore
    @EnvironmentObject var companiesStore: CompaniesStore

    var body: some View {

        List(companiesStore.companies, id: \.self) { comp in
            NavigationLink(value: comp, label: { Label(comp.name, systemImage: "list.bullet") })
        }
        .navigationDestination(for: Company.self) { comp in
            CompanyScreen(data: comp.data)
        }
        .refreshable {
            companiesStore.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Companies").font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    companiesStore.selectedCompany = CompaniesInteractor.emptyCompanyDetails
                    companiesStore.isShowingNewCompanySheet = true
                }
                .sheet(isPresented: $companiesStore.isShowingNewCompanySheet) {
                    NewCompanySheet()
                }
            }
        }
        // It is not called
//        .onAppear {
//            companiesStore.refresh()
//        }
    }
    
}
