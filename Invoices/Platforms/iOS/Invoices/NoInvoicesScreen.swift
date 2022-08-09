//
//  NoInvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NoInvoicesScreen: View {

    @EnvironmentObject private var invoicesState: InvoicesState
    
    var body: some View {
        NoInvoicesView() {
            invoicesState.isShowingNewInvoiceSheet = true
        }
        .sheet(isPresented: $invoicesState.isShowingNewInvoiceSheet) {
            NewInvoiceScreen()
        }
    }

}
