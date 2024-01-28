//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI
import PDFKit

struct Toolbar: ViewModifier {

    @EnvironmentObject var mainViewState: MainViewState
    @ObservedObject var invoiceStore: InvoiceStore
    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                if invoiceStore.isEditing {
                    Text(invoiceStore.editorType == .invoice ? "Edit invoice" : "Edit report")
                } else {
                    Picker("Section", selection: $invoiceStore.editorType) {
                        Text("Invoice").tag(EditorType.invoice)
                        Text("Report").tag(EditorType.report)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: invoiceStore.editorType) { editorType in
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
                Button("Editor") {
                    switch invoiceStore.editorType {
                        case .invoice:
                            invoiceStore.isShowingEditorSheet = true
                        case .report:
                            invoiceStore.isShowingEditorSheet = true
                    }
                }
                .popover(isPresented: $invoiceStore.isShowingEditorSheet,
                         attachmentAnchor: .point(.leading),
                         arrowEdge: .leading) {
                    switch invoiceStore.editorType {
                        case .invoice:
                            InvoiceEditorPopover(invoiceStore: invoiceStore, editorViewModel: invoiceStore.invoiceEditorViewModel)
                        case .report:
                            ReportEditorPopover(invoiceStore: invoiceStore, editorViewModel: invoiceStore.reportEditorViewModel)
                                .frame(width: 500, height: 600)
                    }
                }
                if invoiceStore.isEditing {
                    Button("Preview") {
                        // Dismiss editor
                        invoiceStore.dismissEditor()
                        // Go back to preview mode
                        gotoPreview()
                    }
                } else {
                    Button("Edit \(invoiceStore.editorType == .invoice ? "invoice" : "report")") {
                        switch invoiceStore.editorType {
                            case .invoice:
                                mainViewState.contentType = .invoiceEditor(invoiceStore)
                            case .report:
                                mainViewState.contentType = .reportEditor(invoiceStore)
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

                    if let pdfData = invoiceStore.pdfData,
                       let pdf = PDFDocument(data: pdfData) {
                        ShareLink(item: pdf, preview: SharePreview("PDF"))
                    }
                }
            }
        }

    }

    private func gotoPreview() {
        switch invoiceStore.editorType {
            case .invoice:
                mainViewState.contentType = .invoice(invoiceStore)
            case .report:
                mainViewState.contentType = .report(invoiceStore)
        }
    }

}
