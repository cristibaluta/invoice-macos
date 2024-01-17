//
//  CompaniesList.swift
//  Invoices
//
//  Created by Cristian Baluta on 13.01.2024.
//

import Foundation
import SwiftUI

struct CompaniesList: View {

    @EnvironmentObject var companiesStore: CompaniesStore
    @State private var isShowingCompanyDetailsPopover = false
//    @State private var isShowingAddCompanyPopover = false

    var body: some View {

        Text("Companies").bold().padding(.leading, 16)

        List(companiesStore.companies, id: \.self) { comp in
            Button(comp.name, action: {
                companiesStore.selectedCompany = comp.data
                isShowingCompanyDetailsPopover = true
            })
            .contextMenu {
                Button(action: {
//                        contentColumnState.type = .deleteInvoice(invoice)
                }) {
                    Text("Delete")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .popover(isPresented: $isShowingCompanyDetailsPopover,
                 attachmentAnchor: .rect(.bounds),
                 arrowEdge: .leading) {
            CompanyPopover(data: companiesStore.selectedCompany!)
            .frame(width: 400)
        }
    }

}
