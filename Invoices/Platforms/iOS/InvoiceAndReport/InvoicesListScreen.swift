//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesListScreen: View {

    @EnvironmentObject var store: MainStore
    @ObservedObject var invoicesStore: InvoicesStore


    var body: some View {

        if invoicesStore.invoices.count > 0 {
            invoicesListBody()
        } else {
            noInvoicesBody()
        }
    }

    private func invoicesListBody() -> some View {

        List {
            ForEach(invoicesStore.invoices, id: \.self) { invoice in
                NavigationLink(invoice.name, value: invoice)
            }
            .onDelete(perform: delete)
        }
        .navigationDestination(for: Invoice.self) { invoice in
            InvoiceScreenLoader(invoicesStore: invoicesStore, invoice: invoice)
        }
        .refreshable {
            invoicesStore.loadInvoices()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    invoicesStore.isShowingNewInvoiceSheet = true
                    store.objectWillChange.send()
                }
            }
        }
        .sheet(isPresented: $invoicesStore.isShowingNewInvoiceSheet) {
            NewInvoiceSheet(invoicesStore: invoicesStore)
        }
    }

    private func noInvoicesBody() -> some View {
        NoInvoicesScreen(invoicesStore: invoicesStore)
    }

    private func delete (at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        invoicesStore.deleteInvoice(at: index)
    }

}
