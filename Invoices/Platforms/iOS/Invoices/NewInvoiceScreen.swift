//
//  NewInvoiceScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 19.07.2022.
//

import SwiftUI

struct NewInvoiceScreen: View {

    @EnvironmentObject private var invoicesData: InvoicesStore


    var body: some View {
        NavigationView {
            NewInvoiceView(state: invoicesData.selectedInvoiceContentData.invoiceEditorState)
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.invoicesData.dismissNewInvoice()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        self.invoicesData.selectedInvoiceContentData.calculate()
                        self.invoicesData.selectedInvoiceContentData.save()
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
