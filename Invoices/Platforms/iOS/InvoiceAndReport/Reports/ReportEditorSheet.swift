//
//  ReportEditorSheet.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 22.07.2022.
//

import Foundation
import SwiftUI

struct ReportEditorSheet: View {

    @Environment(\.dismiss) var dismiss
    private var invoiceModel: InvoiceModel
    private var editorModel: ReportEditorModel

    init (model: InvoiceModel) {
        self.invoiceModel = model
        self.editorModel = model.reportEditorViewModel
    }

    var body: some View {

        let _ = Self._printChanges()

        NavigationView {
            ReportEditorView(viewModel: editorModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                            invoiceModel.dismissEditor()
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Edit report").font(.headline)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            invoiceModel.save()
                            invoiceModel.dismissEditor()
                            dismiss()
                        }
                    }
                }
        }
    }

}

