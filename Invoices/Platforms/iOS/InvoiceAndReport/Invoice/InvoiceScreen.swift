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
            HtmlViewer(htmlString: model.html, wrappedPdfData: model.wrappedPdfData)
                .frame(width: context.size.width - 20,
                       height: (context.size.width - 20) * HtmlViewer.size.height / HtmlViewer.size.width)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .padding(10)
        }
        .background(Color(.systemGray4))
        .navigationBarTitle("", displayMode: .inline)
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
                            .interactiveDismissDisabled()
                    } else {
                        ReportEditorSheet(model: model)
                            .interactiveDismissDisabled()
                    }
                }
            }
        }
    }

}
