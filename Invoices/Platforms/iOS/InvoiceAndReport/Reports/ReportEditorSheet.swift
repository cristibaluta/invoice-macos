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
    private var invoiceStore: InvoiceStore
    private var viewModel: ReportEditorViewModel

    init (invoiceStore: InvoiceStore) {
        self.invoiceStore = invoiceStore
        self.viewModel = invoiceStore.reportEditorViewModel
    }

    var body: some View {

        let _ = Self._printChanges()

        NavigationView {
            ScrollView {
                ReportEditor(viewModel: viewModel)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit report").font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        invoiceStore.save()
                        invoiceStore.dismissEditor()
                        dismiss()
                    }
                }
            }
        }
    }

}

