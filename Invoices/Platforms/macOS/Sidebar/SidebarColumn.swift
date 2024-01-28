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
    @EnvironmentObject var mainWindowState: MainWindowState


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
                    invoicesStore.chartCancellable = invoicesStore.chartPublisher.sink { chartsViewModel in
                        if invoicesStore.invoices.isEmpty {
                            mainWindowState.contentType = .noInvoices
                        } else {
                            mainWindowState.contentType = .charts(chartsViewModel)
                        }
                    }
                    invoicesStore.newInvoiceCancellable = invoicesStore.newInvoicePublisher.sink { contentData in
                        mainWindowState.contentType = .invoice(contentData)
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
