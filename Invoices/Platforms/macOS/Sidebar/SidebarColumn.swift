//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI
import Combine

struct SidebarColumn: View {

    @EnvironmentObject var store: Store
    @EnvironmentObject var mainViewState: MainViewState


    var body: some View {

        let _ = Self._printChanges()
        
        VStack(alignment: .leading) {

            // Projects section
            ProjectsMenu(projectsStore: store.projectsStore)
            .padding(.leading, 16)
            .padding(.trailing, 16)

            Divider().padding(16)

            // Invoices section
            if let invoicesStore = store.projectsStore.invoicesStore {
                InvoicesList(invoicesStore: invoicesStore)
            }

            Spacer()
            Divider().padding(16)

            // Companies section
            CompaniesList()
        }
//        .onAppear {
//            mainViewState.chartCancellable = store.projectsStore.invoicesStore!.chartPublisher.sink { values in
//                if store.projectsStore.invoicesStore?.invoices.isEmpty ?? false {
//                    mainViewState.type = .noInvoices
//                } else {
//                    mainViewState.type = .charts(values.0, values.1, values.2)
//                }
//            }
//            mainViewState.newInvoiceCancellable = store.projectsStore.invoicesStore!.newInvoicePublisher.sink { contentData in
////                mainViewState.contentData = contentData
////                mainViewState.type = .invoice(contentData)
//            }
//        }

    }

}
