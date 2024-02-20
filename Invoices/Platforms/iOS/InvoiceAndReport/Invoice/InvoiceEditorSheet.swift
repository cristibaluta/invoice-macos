//
//  InvoideEditingScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 16.07.2022.
//

import UIKit
import SwiftUI

struct InvoiceEditorSheet: View {

    @EnvironmentObject var companiesStore: CompaniesStore
    @Environment(\.dismiss) var dismiss
    private var invoiceStore: InvoiceStore
    private var viewModel: InvoiceEditorViewModel

    init (invoiceStore: InvoiceStore) {
        self.invoiceStore = invoiceStore
        self.viewModel = invoiceStore.invoiceEditorViewModel
    }

    var body: some View {

        let _ = Self._printChanges()
        
        NavigationView {
            ScrollView {
                InvoiceEditor(viewModel: viewModel, onTapAddCompany: {
                    self.companiesStore.isShowingNewCompanySheet = true
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
//                        dismiss()
                        invoiceStore.dismissEditor()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit invoice").font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        invoiceStore.save()
                        invoiceStore.dismissEditor()
//                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $companiesStore.isShowingNewCompanySheet) {
                NewCompanySheet()
            }
            .onTapGesture {
                endEditing()
            }
        }
    }

    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}
