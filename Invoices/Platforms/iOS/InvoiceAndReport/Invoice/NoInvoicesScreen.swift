//
//  NoInvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NoInvoicesScreen: View {

    @ObservedObject var invoicesStore: InvoicesStore

    var body: some View {
        NoInvoicesView() {
            invoicesStore.isShowingNewInvoiceSheet = true
        }
        .sheet(isPresented: $invoicesStore.isShowingNewInvoiceSheet) {
            NewInvoiceScreen(invoicesStore: invoicesStore)
        }
    }

}
