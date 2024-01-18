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
    var isEditing: Bool
    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Section", selection: $mainViewState.editorType) {
                    Text("Invoice").tag(EditorType.invoice)
                    Text("Report").tag(EditorType.report)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: mainViewState.editorType) { editorType in
                    invoiceStore.editorType = editorType
                    switch editorType {
                        case .invoice:
                            mainViewState.contentType = .invoice(invoiceStore)
                        case .report:
                            mainViewState.contentType = .report(invoiceStore)
                    }
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                if isEditing {
                    Button("Save \(mainViewState.editorType == .invoice ? "invoice" : "report")") {
                        // Save the invoice
                        invoiceStore.save()
                        // Go back to preview mode
                        switch mainViewState.editorType {
                            case .invoice:
                                mainViewState.contentType = .invoice(invoiceStore)
                            case .report:
                                mainViewState.contentType = .report(invoiceStore)
                        }
                    }
                } else {
                    Button("Edit \(mainViewState.editorType == .invoice ? "invoice" : "report")") {
                        //                    invoiceStore.isShowingEditorSheet = true
                        switch mainViewState.editorType {
                            case .invoice:
                                mainViewState.contentType = .invoiceEditor(invoiceStore)
                            case .report:
                                mainViewState.contentType = .reportEditor(invoiceStore)
                        }
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

}
