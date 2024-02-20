//
//  InvoiceView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 08.01.2022.
//

import SwiftUI

struct InvoiceAndReportScreen: View {

    @ObservedObject var invoicesStore: InvoicesStore
    @ObservedObject var model: InvoiceAndReportModel
    @State private var isShowingEditInvoiceSheet = false

    
    var body: some View {

        let _ = Self._printChanges()

        GeometryReader { context in
            ScrollView {
                if let invoiceStore = model.invoiceStore {
                    HtmlViewer(htmlString: model.html, wrappedPdfData: invoiceStore.wrappedPdfData)
                        .frame(width: context.size.width,
                               height: context.size.width * HtmlViewer.size.height / HtmlViewer.size.width)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Type", selection: $model.editorType) {
                    Text("Invoice").tag(EditorType.invoice)
                    Text("Reports").tag(EditorType.report)
                }
                .frame(width: 150)
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: model.editorType) { newValue in
                    model.editorType = newValue
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditInvoiceSheet = true
                }
                .sheet(isPresented: $isShowingEditInvoiceSheet) {
                    if model.editorType == .invoice {
                        if let invoiceStore = model.invoiceStore {
                            InvoiceEditorSheet(viewModel: invoiceStore.invoiceEditorViewModel) { newData in
                                model.invoiceStore?.save()
                            }
                        } else {
                            Text("Missing model")
                        }
                    } else {
                        if let invoiceStore = model.invoiceStore {
                            ReportEditorSheet(viewModel: invoiceStore.reportEditorViewModel) { newData in
                                model.invoiceStore?.save()
                            }
                        } else {
                            Text("Missing model")
                        }
                    }
                }
            }
        }
        .onAppear() {
            _ = invoicesStore.loadInvoice(model.invoice)
            .sink {
//                $0.calculate()
                self.model.invoiceStore = $0
            }
        }
    }

}
