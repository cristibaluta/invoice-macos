//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI
import Combine

struct SidebarColumn: View {

    @EnvironmentObject var store: MainStore
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
                .task(id: invoicesStore.id) {
                    mainViewState.chartCancellable = invoicesStore.chartPublisher.sink { chartsViewModel in
                        if invoicesStore.invoices.isEmpty {
                            mainViewState.contentType = .noInvoices
                        } else {
                            mainViewState.contentType = .charts(chartsViewModel)
                        }
                    }
                    mainViewState.newInvoiceCancellable = invoicesStore.newInvoicePublisher.sink { contentData in
                        mainViewState.contentType = .invoice(contentData)
                    }
                }
            }

            Spacer()
            Divider().padding(16)

            // Companies section
            CompaniesList()
        }

    }

}
