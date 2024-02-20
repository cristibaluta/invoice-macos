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
    private var viewModel: ReportEditorViewModel
    private let onSave: (InvoiceData) -> Void

    init (viewModel: ReportEditorViewModel, onSave: @escaping (InvoiceData) -> Void) {
        self.viewModel = viewModel
        self.onSave = onSave
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
                        dismiss.callAsFunction()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit report").font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        onSave(viewModel.data)
                        dismiss.callAsFunction()
                    }
                }
            }
        }
    }

}

