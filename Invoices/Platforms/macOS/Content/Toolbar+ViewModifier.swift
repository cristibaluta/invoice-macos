//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI

struct Toolbar: ViewModifier {

    @EnvironmentObject var contentColumnState: ContentColumnState
    @ObservedObject var invoiceReportState: InvoiceAndReportState
    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Section", selection: $invoiceReportState.contentType) {
                    Text("Invoice").tag(ContentType.invoice)
                    Text("Report").tag(ContentType.report)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: invoiceReportState.contentType) { tag in
                    invoiceReportState.contentType = tag
                    invoiceReportState.calculate()
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Edit \(invoiceReportState.contentType == .invoice ? "invoice" : "report")") {
                    invoiceReportState.isShowingEditorSheet = true
                }
                .popover(isPresented: $invoiceReportState.isShowingEditorSheet) {
                    switch invoiceReportState.contentType {
                        case .invoice: InvoiceEditorPopover(state: invoiceReportState)
                        case .report:
                            ReportEditorPopover(state: invoiceReportState) { newInvoiceData in
                                // This will trigger the webview to reload. Getting the info directly from invoiceReportState does not
                                contentColumnState.html = invoiceReportState.html
                            }
                            .frame(width: 500, height: 600)
                    }
                }
                
                Button(action: {
                    isShowingExportPopover = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .popover(isPresented: $isShowingExportPopover) {
                    SavePopover(state: invoiceReportState)
                    .padding(20)
                }
            }
        }

    }

}
