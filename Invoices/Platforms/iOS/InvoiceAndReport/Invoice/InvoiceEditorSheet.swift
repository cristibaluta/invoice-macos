//
//  InvoideEditingScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 16.07.2022.
//

import UIKit
import SwiftUI

struct InvoiceEditorSheet: View {

    @EnvironmentObject var companiesData: CompaniesStore
    @Environment(\.dismiss) var dismiss
    private var viewModel: InvoiceEditorViewModel
    private let onSave: (InvoiceData) -> Void

    init (viewModel: InvoiceEditorViewModel, onSave: @escaping (InvoiceData) -> Void) {
        self.viewModel = viewModel
        self.onSave = onSave
    }

    var body: some View {

        let _ = Self._printChanges()
        
        NavigationView {
            ScrollView {
                InvoiceEditor(viewModel: viewModel, onTapAddCompany: {
                    self.companiesData.isShowingNewCompanySheet = true
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit invoice").font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        onSave(viewModel.data)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $companiesData.isShowingNewCompanySheet) {
                NewCompanySheet()
            }
            .onTapGesture {
                self.endEditing()
            }
        }
    }

    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}