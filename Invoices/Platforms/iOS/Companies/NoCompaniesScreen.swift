//
//  NoCompanyView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2022.
//

import SwiftUI

struct NoCompaniesScreen: View {

    @EnvironmentObject private var companiesState: CompaniesState

    var body: some View {
        NoCompaniesView() {
            companiesState.isShowingNewCompanySheet = true
        }
        .sheet(isPresented: $companiesState.isShowingNewCompanySheet) {
            NewCompanySheet()
        }
    }
}
