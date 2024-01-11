//
//  NewInvoiceScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 19.07.2022.
//

import SwiftUI

struct NewInvoiceScreen: View {

    @EnvironmentObject private var invoicesData: InvoicesData


    var body: some View {
        NavigationView {
            NewInvoiceView(state: invoicesData.selectedInvoiceState.invoiceEditorState)
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.invoicesData.dismissNewInvoice()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        self.invoicesData.selectedInvoiceState.calculate()
                        self.invoicesData.selectedInvoiceState.save()
                        self.invoicesData.dismissNewInvoice()
                    }
                }
            }
            .onAppear {
                invoicesData.createNextInvoiceInProject()
            }
        }
        
    }

}
