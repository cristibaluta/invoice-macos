//
//  CompaniesList.swift
//  Invoices
//
//  Created by Cristian Baluta on 13.01.2024.
//

import Foundation
import SwiftUI

struct CompaniesList: View {

    @EnvironmentObject var mainViewState: MainViewState
    @EnvironmentObject var companiesStore: CompaniesStore
    @State private var isShowingCompanyDetailsPopover = false
//    @State private var isShowingAddCompanyPopover = false

    var body: some View {

        Text("Companies").bold()
        .padding(.leading, 16)
        .padding(.bottom, 4)

        Text("+ New company").onTapGesture {
            mainViewState.contentType = .company(CompaniesInteractor.emptyCompanyDetails)
        }
        .padding(.leading, 16)

        List(companiesStore.companies, id: \.self) { comp in
            Button(comp.name, action: {
                companiesStore.selectedCompany = comp.data
                companiesStore.isShowingNewCompanySheet = true
            })
            .padding(0)
            .contextMenu {
                Button(action: {
//                    mainViewState.contentType = .deleteC
                    companiesStore.delete(comp.data)
                }) {
                    Text("Delete")
                }
            }
        }
        .frame(height: CGFloat(min(4, companiesStore.companies.count)) * 32)
        .listStyle(SidebarListStyle())
        .popover(isPresented: $companiesStore.isShowingNewCompanySheet,
                 attachmentAnchor: .rect(.bounds),
                 arrowEdge: .trailing) {
            CompanyPopover(data: companiesStore.selectedCompany ?? CompaniesInteractor.emptyCompanyDetails)
            .frame(width: 400)
        }

    }

}
