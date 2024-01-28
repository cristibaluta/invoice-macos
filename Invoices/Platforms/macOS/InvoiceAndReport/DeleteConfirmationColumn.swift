//
//  DeleteConfirmationView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.01.2022.
//

import SwiftUI

struct DeleteConfirmationColumn: View {

    @EnvironmentObject private var mainWindowState: MainWindowState
    @EnvironmentObject private var mainStore: MainStore

    var invoice: Invoice
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Text("Delete invoice").font(.system(size: 40)).bold().padding(10)
            Text("Are you sure you want to delete invoice \(invoice.name)? This operation is irreversible.").multilineTextAlignment(.center)

            Spacer().frame(height: 20)

            HStack {
                Button("Cancel") {
                    mainWindowState.contentType = .noProjects
                }
                Button("Delete") {
                    mainStore.projectsStore.invoicesStore?.deleteInvoice(invoice)
                }
            }
            Spacer()
        }
    }
    
}
