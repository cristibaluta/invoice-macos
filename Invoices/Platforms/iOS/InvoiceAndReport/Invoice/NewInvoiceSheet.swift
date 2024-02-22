//
//  NewInvoiceScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 19.07.2022.
//

import SwiftUI

struct NewInvoiceSheet: View {

    @EnvironmentObject var companiesStore: CompaniesStore
    @ObservedObject var invoicesStore: InvoicesStore


    var body: some View {
        NavigationView {
            if let editorModel = invoicesStore.selectedInvoiceModel?.invoiceEditorViewModel {
                // Add only few fields
//                NewInvoiceView(viewModel: editorModel)
                InvoiceEditorView(model: editorModel, onTapAddCompany: {
                    self.companiesStore.isShowingNewCompanySheet = true
                })
                .padding(20)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            invoicesStore.dismissNewInvoice()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            invoicesStore.selectedInvoiceModel?.save()
                            invoicesStore.dismissNewInvoice()
                        }
                    }
                }
            } else {
                Text("Loading...")
                .onAppear {
                    invoicesStore.createNextInvoiceInProject()
                }
            }
        }
        
    }

}
