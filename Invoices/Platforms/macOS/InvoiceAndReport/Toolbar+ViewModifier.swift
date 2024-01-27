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
                if invoiceStore.isEditing {
                    Text(mainViewState.editorType == .invoice ? "Edit invoice" : "Edit report")
                } else {
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
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                if invoiceStore.isEditing {
                    Button("Preview") {
                        // Dismiss editor
                        invoiceStore.dismissEditor()
                        // Go back to preview mode
                        gotoPreview()
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
                                InvoiceEditorPopover(invoiceStore: invoiceStore, editorViewModel: invoiceStore.invoiceEditorViewModel)
                            case .report:
                                ReportEditorPopover(invoiceStore: invoiceStore, editorViewModel: invoiceStore.reportEditorViewModel)
                                    .frame(width: 500, height: 600)
                        }
                    }
                    if invoiceStore.hasChanges {
                        Button("Save") {
                            // Save the invoice
                            invoiceStore.save()
                            // Go back to preview mode
                            gotoPreview()
                        }
                    }
//                    Button(action: {
//                        isShowingExportPopover = true
//                    }) {
//                        Image(systemName: "square.and.arrow.up")
//                    }
//                    .popover(isPresented: $isShowingExportPopover) {
//                        ExportPopover(state: invoiceStore)
//                            .padding(20)
//                    }

                    ShareLink(item: "Test share")
                }
            }
        }

    }

    private func gotoPreview() {
        switch mainViewState.editorType {
            case .invoice:
                mainViewState.contentType = .invoice(invoiceStore)
            case .report:
                mainViewState.contentType = .report(invoiceStore)
        }
    }

}
