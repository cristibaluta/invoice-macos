//
//  NewInvoiceScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 19.07.2022.
//

import SwiftUI

struct NewInvoiceScreen: View {

    @EnvironmentObject private var invoicesState: InvoicesState


    var body: some View {
        NavigationView {
            NewInvoiceView(state: invoicesState.selectedInvoiceState.invoiceEditorState)
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.invoicesState.dismissNewInvoice()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        self.invoicesState.selectedInvoiceState.calculate()
                        self.invoicesState.selectedInvoiceState.save()
                        self.invoicesState.dismissNewInvoice()
                    }
                }
            }
            .onAppear {
                invoicesState.createNextInvoiceInProject()
            }
        }
        
    }

}
