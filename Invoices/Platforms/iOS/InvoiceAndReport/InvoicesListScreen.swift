//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesListScreen: View {

    @EnvironmentObject var store: MainStore
    var project: Project


    var body: some View {

        if let invoicesStore = store.projectsStore.invoicesStore {
            if invoicesStore.invoices.count > 0 {
                invoicesListBody(with: invoicesStore)
            } else {
                noInvoicesBody(with: invoicesStore)
            }
        } else {
            Text("Loading...")
            .onAppear {
                store.projectsStore.selectedProject = project
            }
        }
    }

    private func invoicesListBody (with invoicesStore: InvoicesStore) -> some View {

        List {
            ForEach(invoicesStore.invoices, id: \.self) { invoice in
                NavigationLink(invoice.name, value: invoice)
            }
            .onDelete(perform: delete)
        }
        .navigationDestination(for: Invoice.self) { invoice in
            Text("Invoice details for \(invoice.name)")
//            InvoiceAndReportScreen(state: InvoiceAndReportScreenState(invoice: invoice, contentData: invoicesStore.selectedInvoiceContentData))
        }
        .refreshable {
            invoicesStore.loadInvoices()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(project.name).font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    store.projectsStore.invoicesStore?.isShowingNewInvoiceSheet = true
                }
            }
        }
//        .sheet(isPresented: $store.projectsStore.invoicesStore!.isShowingNewInvoiceSheet) {
//            NewInvoiceScreen()
//        }
    }

    private func noInvoicesBody (with invoicesStore: InvoicesStore) -> some View {

        NoInvoicesScreen(invoicesStore: invoicesStore)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(project.name).font(.headline)
            }
        }
    }

    private func delete (at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        store.projectsStore.invoicesStore?.deleteInvoice(at: index)
    }

}