//
//  InvoicesList.swift
//  Invoices
//
//  Created by Cristian Baluta on 13.01.2024.
//

import Foundation
import SwiftUI

struct InvoicesList: View {

    @EnvironmentObject var mainViewState: MainViewState
    @ObservedObject var invoicesStore: InvoicesStore

    var body: some View {

        let _ = Self._printChanges()

        Text("Invoices").bold().padding(.leading, 16)

        List(invoicesStore.invoices, id: \.self, selection: $invoicesStore.selectedInvoice) { invoice in
            HStack {
                Text(invoice.name)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                _ = invoicesStore.loadInvoice(invoice)
                    .sink { invoiceStore in
                        mainViewState.contentType = .invoice(invoiceStore)
                    }
            }
            .contextMenu {
                Button(action: {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: invoicesStore.path(for: invoice))
                }) {
                    Text("Show in Finder")
                }
                Button(action: {
                    mainViewState.contentType = .deleteInvoice(invoice)
                }) {
                    Text("Delete")
                }
            }
        }
        .listStyle(SidebarListStyle())
    }

}
