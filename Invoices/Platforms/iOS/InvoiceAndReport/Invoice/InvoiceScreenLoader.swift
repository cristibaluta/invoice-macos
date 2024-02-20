//
//  InvoiceScreenLoader.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 21.02.2024.
//

import Foundation
import SwiftUI

struct InvoiceScreenLoader: View {

    @ObservedObject var invoicesStore: InvoicesStore
    var invoice: Invoice

    var body: some View {

        let _ = Self._printChanges()

        if let model = invoicesStore.selectedInvoiceModel {
            InvoiceScreen(model: model)
        } else {
            Text("Loading...")
                .task {
                    _ = invoicesStore.loadInvoice(invoice)
                    .sink { invoiceModel in
                    }
                }
        }
    }

}
