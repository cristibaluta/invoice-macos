//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesListScreen: View {

    @EnvironmentObject private var invoicesState: InvoicesState
    private var project: Project

    init (folder: Project) {
        self.project = folder
    }
    
    var body: some View {

        if $invoicesState.invoices.count > 0 {
            invoicesListBody
        } else {
            noInvoicesBody
        }
    }

    private var invoicesListBody: some View {

        List {
            ForEach(invoicesState.invoices, id: \.self) { invoice in
                NavigationLink(destination: InvoiceAndReportScreen(state: InvoiceAndReportScreenState(invoice: invoice, invoiceReportState: invoicesState.selectedInvoiceState))) {
                    Label(invoice.name, systemImage: "doc.text")
                }
            }
            .onDelete(perform: delete)
        }
        .refreshable {
            invoicesState.refresh(project)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(project.name).font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    invoicesState.isShowingNewInvoiceSheet = true
                }
            }
        }
        .sheet(isPresented: $invoicesState.isShowingNewInvoiceSheet) {
            NewInvoiceScreen()
        }
        .onAppear {
            invoicesState.refresh(project)
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
            invoicesState.refresh(project)
        }
    }

    private func delete (at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        invoicesState.deleteInvoice(at: index)
    }

}
