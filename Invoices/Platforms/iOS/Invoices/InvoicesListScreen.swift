//
//  InvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.01.2022.
//

import SwiftUI

struct InvoicesListScreen: View {

    @EnvironmentObject private var invoicesData: InvoicesStore
    private var project: Project

    init (folder: Project) {
        self.project = folder
    }
    
    var body: some View {

        if $invoicesData.invoices.count > 0 {
            invoicesListBody
        } else {
            noInvoicesBody
        }
    }

    private var invoicesListBody: some View {

        List {
            ForEach(invoicesData.invoices, id: \.self) { invoice in
                NavigationLink(destination: InvoiceAndReportScreen(state: InvoiceAndReportScreenState(invoice: invoice, contentData: invoicesData.selectedInvoiceContentData))) {
                    Label(invoice.name, systemImage: "doc.text")
                }
            }
            .onDelete(perform: delete)
        }
        .refreshable {
            invoicesData.refresh(project)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(project.name).font(.headline)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    invoicesData.isShowingNewInvoiceSheet = true
                }
            }
        }
        .sheet(isPresented: $invoicesData.isShowingNewInvoiceSheet) {
            NewInvoiceScreen()
        }
        .onAppear {
            invoicesData.refresh(project)
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
            invoicesData.refresh(project)
        }
    }

    private func delete (at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        invoicesData.deleteInvoice(at: index)
    }

}
