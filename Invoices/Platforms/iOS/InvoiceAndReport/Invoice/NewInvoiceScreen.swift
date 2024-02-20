//
//  NewInvoiceScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 19.07.2022.
//

import SwiftUI

struct NewInvoiceScreen: View {

    @ObservedObject var invoicesStore: InvoicesStore


    var body: some View {
        NavigationView {
            if let invoiceModel = invoicesStore.selectedInvoiceModel {
//                NewInvoiceView(viewModel: invoicesStore.selectedInvoiceContentData.invoiceEditorState)
                Text("New invoice placeholder")
                .padding(20)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.invoicesStore.dismissNewInvoice()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
//                                self.invoicesStore.selectedInvoiceContentData.calculate()
//                                self.invoicesStore.selectedInvoiceContentData.save()
//                                self.invoicesStore.dismissNewInvoice()
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
