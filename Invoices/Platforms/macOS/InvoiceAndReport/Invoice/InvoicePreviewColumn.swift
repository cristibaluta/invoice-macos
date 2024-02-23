//
//  InvoicePreviewColumn.swift
//  Invoices
//
//  Created by Cristian Baluta on 22.02.2024.
//

import Foundation
import SwiftUI

struct InvoicePreviewColumn: View {

    @ObservedObject var invoiceModel: InvoiceModel

    var body: some View {

        let _ = Self._printChanges()

        HtmlViewer(htmlString: invoiceModel.html, wrappedPdfData: invoiceModel.wrappedPdfData)
            .frame(width: 920)
            .padding(10)
            .modifier(Toolbar(invoiceModel: invoiceModel))
            .task(id: invoiceModel.id) { }
    }

}
