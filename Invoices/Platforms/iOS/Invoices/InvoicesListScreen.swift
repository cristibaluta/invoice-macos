//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesListScreen: View {

    @EnvironmentObject var store: MainStore
    @EnvironmentObject var invoicesStore: InvoicesStore
    var project: Project

    init (project: Project) {
        self.project = project
//        invoicesStore = store.projectsStore.invoicesStore!
//        store.projectsStore.selectedProject = project
    }
    
    var body: some View {

        if let invoiceStore = store.projectsStore.invoicesStore {
            if invoicesStore.invoices.count > 0 {
                invoicesListBody
            } else {
                noInvoicesBody
            }
        } else {
            Text("No InvoicesStore")
        }
    }

    private var invoicesListBody: some View {

        List {
            ForEach(invoicesStore.invoices, id: \.self) { invoice in
//                NavigationLink(destination: InvoiceAndReportScreen(state: InvoiceAndReportScreenState(invoice: invoice, contentData: invoicesStore.selectedInvoiceContentData))) {
//                    Label(invoice.name, systemImage: "doc.text")
//                }
            }
            .onDelete(perform: delete)
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
                    invoicesStore.isShowingNewInvoiceSheet = true
                }
            }
        }
        .sheet(isPresented: $invoicesStore.isShowingNewInvoiceSheet) {
            NewInvoiceScreen()
        }
        .onAppear {
            invoicesStore.loadInvoices()
        }
    }

    private var noInvoicesBody: some View {

        NoInvoicesScreen()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(project.name).font(.headline)
            }
        }
        .onAppear {
            invoicesStore.loadInvoices()
        }
    }

    private func delete (at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        invoicesStore.deleteInvoice(at: index)
    }

}
