//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI

struct Toolbar: ViewModifier {

    @EnvironmentObject var mainViewState: MainViewState
    @ObservedObject var invoiceStore: InvoiceStore
    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Section", selection: $mainViewState.editorType) {
                    Text("Invoice").tag(EditorType.invoice)
                    Text("Report").tag(EditorType.report)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: mainViewState.editorType) { tag in
//                    contentData.contentType = tag
//                    contentData.calculate()
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Edit \(mainViewState.editorType == .invoice ? "invoice" : "report")") {
                    invoiceStore.isShowingEditorSheet = true
                }
                .popover(isPresented: $invoiceStore.isShowingEditorSheet,
                         attachmentAnchor: .point(.leading),
                         arrowEdge: .leading) {
                    switch mainViewState.editorType {
                        case .invoice:
                            InvoiceEditorPopover(invoiceStore: invoiceStore, editorViewModel: invoiceStore.createInvoiceEditor())
                        case .report:
                            ReportEditorPopover(invoiceStore: invoiceStore, editorViewModel: invoiceStore.createReportEditor())
                            .frame(width: 500, height: 600)
                    }
                }
                
                Button(action: {
                    isShowingExportPopover = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .popover(isPresented: $isShowingExportPopover) {
                    ExportPopover(state: invoiceStore)
                    .padding(20)
                }
            }
        }

    }

}
