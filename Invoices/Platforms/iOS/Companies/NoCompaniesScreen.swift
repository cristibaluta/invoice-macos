//
//  NoCompanyView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2022.
//

import SwiftUI

struct NoCompaniesScreen: View {

    @EnvironmentObject var companiesStore: CompaniesStore

    var body: some View {
        NoCompaniesView() {
            companiesStore.isShowingNewCompanySheet = true
        }
        .sheet(isPresented: $companiesStore.isShowingNewCompanySheet) {
            NewCompanySheet()
        }
    }
}
