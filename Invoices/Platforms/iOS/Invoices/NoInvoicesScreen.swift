//
//  NoInvoicesView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NoInvoicesScreen: View {

    @EnvironmentObject private var invoicesData: InvoicesStore
    
    var body: some View {
        NoInvoicesView() {
            invoicesData.isShowingNewInvoiceSheet = true
        }
        .sheet(isPresented: $invoicesData.isShowingNewInvoiceSheet) {
            NewInvoiceScreen()
        }
    }

}
