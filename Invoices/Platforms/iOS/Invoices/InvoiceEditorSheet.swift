//
//  InvoideEditingScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 16.07.2022.
//

import UIKit
import SwiftUI

struct InvoiceEditorSheet: View {

    @EnvironmentObject var companiesData: CompaniesData
    @Environment(\.dismiss) var dismiss
    private var state: InvoiceEditorState
    private let onSave: (InvoiceData) -> Void

    init (data: InvoiceData, onSave: @escaping (InvoiceData) -> Void) {
        self.onSave = onSave
        self.state = InvoiceEditorState(data: data)
    }

    var body: some View {

        let _ = Self._printChanges()
        
        NavigationView {
            ScrollView {
                InvoiceEditor(state: state, onTapAddCompany: {
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
                        onSave(state.data)
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
