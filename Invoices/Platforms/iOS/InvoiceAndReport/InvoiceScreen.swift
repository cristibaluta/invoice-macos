//
//  InvoiceView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 08.01.2022.
//

import SwiftUI

struct InvoiceScreen: View {

    @ObservedObject var model: InvoiceModel

    
    var body: some View {

        let _ = Self._printChanges()

        GeometryReader { context in
            ScrollView {
                HtmlViewer(htmlString: model.html, wrappedPdfData: model.wrappedPdfData)
                    .frame(width: context.size.width,
                           height: context.size.width * HtmlViewer.size.height / HtmlViewer.size.width)
            }
            .navigationBarTitle("", displayMode: .inline)
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
                    model.isEditing = true
                }
                .sheet(isPresented: $model.isEditing) {
                    if model.editorType == .invoice {
                        InvoiceEditorSheet(model: model)
                    } else {
                        ReportEditorSheet(model: model)
                    }
                }
            }
        }
    }

}
