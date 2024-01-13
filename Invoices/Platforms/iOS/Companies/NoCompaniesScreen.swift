//
//  NoCompanyView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2022.
//

import SwiftUI

struct NoCompaniesScreen: View {

    @EnvironmentObject private var companiesData: CompaniesStore

    var body: some View {
        NoCompaniesView() {
            companiesData.isShowingNewCompanySheet = true
        }
        .sheet(isPresented: $companiesData.isShowingNewCompanySheet) {
            NewCompanySheet()
        }
    }
}
