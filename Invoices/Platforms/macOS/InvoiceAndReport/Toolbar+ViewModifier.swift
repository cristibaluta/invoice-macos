//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI
import PDFKit

struct Toolbar: ViewModifier {

    @EnvironmentObject var mainWindowState: MainWindowState
    @ObservedObject var invoiceModel: InvoiceModel
    @State private var isShowingEditorPopover = false
//    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        let _ = Self._printChanges()

        content.toolbar {
            ToolbarItem(placement: .principal) {
                if invoiceModel.isEditing {
                    Text(invoiceModel.editorType == .invoice ? "Edit invoice" : "Edit report")
                } else {
                    Picker("Section", selection: $invoiceModel.editorType) {
                        Text("Invoice").tag(EditorType.invoice)
                        Text("Report").tag(EditorType.report)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: invoiceModel.editorType) { editorType in
                        invoiceModel.editorType = editorType
                        switch editorType {
                            case .invoice:
                                mainWindowState.contentType = .invoice(invoiceModel)
                            case .report:
                                mainWindowState.contentType = .report(invoiceModel)
                        }
                    }
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Editor") {
                    switch invoiceModel.editorType {
                        case .invoice:
                            isShowingEditorPopover = true
                        case .report:
                            isShowingEditorPopover = true
                    }
                }
                .popover(isPresented: $isShowingEditorPopover,
                         attachmentAnchor: .point(.trailing),
                         arrowEdge: .trailing) {
                    switch invoiceModel.editorType {
                        case .invoice:
                            InvoiceEditorPopover(invoiceModel: invoiceModel, editorModel: invoiceModel.invoiceEditorModel)
                        case .report:
                            ReportEditorPopover(invoiceModel: invoiceModel, editorModel: invoiceModel.reportEditorModel)
                                .frame(width: 500, height: 600)
                    }
                }
                if invoiceModel.isEditing {
                    Button("Preview") {
                        // Dismiss editor
                        invoiceModel.dismissEditor()
                        // Go back to preview mode
                        gotoPreview()
                    }
                } else {
                    Button("Edit") {
                        switch invoiceModel.editorType {
                            case .invoice:
                                mainWindowState.contentType = .invoiceEditor(invoiceModel)
                            case .report:
                                mainWindowState.contentType = .reportEditor(invoiceModel)
                        }
                    }
                    if invoiceModel.hasChanges {
                        Button("Save") {
                            // Save the invoice
                            invoiceModel.save()
                        }
                    }
//                    Button(action: {
//                        isShowingExportPopover = true
//                    }) {
//                        Image(systemName: "square.and.arrow.up")
//                    }
//                    .popover(isPresented: $isShowingExportPopover) {
//                        ExportPopover(state: invoiceModel)
//                            .padding(20)
//                    }

//                    if let pdfData = invoiceModel.pdfData,
                    if let pdf = PDFDocument(data: invoiceModel.wrappedPdfData.data) {
                        ShareLink(item: pdf, preview: SharePreview("PDF"))
                    }
                }
            }
        }

    }

    private func gotoPreview() {
        switch invoiceModel.editorType {
            case .invoice:
                mainWindowState.contentType = .invoice(invoiceModel)
            case .report:
                mainWindowState.contentType = .report(invoiceModel)
        }
    }

}
