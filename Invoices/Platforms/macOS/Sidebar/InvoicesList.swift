//
//  InvoicesList.swift
//  Invoices
//
//  Created by Cristian Baluta on 13.01.2024.
//

import Foundation
import SwiftUI

struct InvoicesList: View {

    @EnvironmentObject var mainViewState: MainViewState
    @ObservedObject var invoicesStore: InvoicesStore
    @State private var selectedInvoice: Invoice? {
        didSet {
            _ = invoicesStore.loadInvoice(selectedInvoice!)
                .sink { contentData in
                    mainViewState.type = .invoice(contentData)
                    contentData.calculate()
                }
        }
    }

    var body: some View {

        Text("Invoices").bold().padding(.leading, 16)
        List(invoicesStore.invoices, id: \.self, selection: $selectedInvoice) { invoice in
            HStack {
                Text(invoice.name)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedInvoice = invoice
            }
            .contextMenu {
                Button(action: {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: invoicesStore.path(for: invoice))
                }) {
                    Text("Show in Finder")
                }
                Button(action: {
                    mainViewState.type = .deleteInvoice(invoice)
                }) {
                    Text("Delete")
                }
            }
        }
        .listStyle(SidebarListStyle())
    }

}
