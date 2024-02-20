//
//  InvoiceView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 08.01.2022.
//

import SwiftUI

struct InvoiceScreen: View {

    @ObservedObject var invoiceStore: InvoiceStore

    
    var body: some View {

        let _ = Self._printChanges()

        GeometryReader { context in
            ScrollView {
                HtmlViewer(htmlString: invoiceStore.html, wrappedPdfData: invoiceStore.wrappedPdfData)
                    .frame(width: context.size.width,
                           height: context.size.width * HtmlViewer.size.height / HtmlViewer.size.width)
            }
            .navigationBarTitle("", displayMode: .inline)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Type", selection: $invoiceStore.editorType) {
                    Text("Invoice").tag(EditorType.invoice)
                    Text("Reports").tag(EditorType.report)
                }
                .frame(width: 150)
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: invoiceStore.editorType) { newValue in
                    invoiceStore.editorType = newValue
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    invoiceStore.isEditing = true
                }
                .sheet(isPresented: $invoiceStore.isEditing) {
                    if invoiceStore.editorType == .invoice {
                        InvoiceEditorSheet(invoiceStore: invoiceStore)
                    } else {
                        ReportEditorSheet(invoiceStore: invoiceStore)
                    }
                }
            }
        }
    }

}
