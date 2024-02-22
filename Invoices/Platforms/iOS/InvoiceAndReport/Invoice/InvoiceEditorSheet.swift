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
    private var invoiceModel: InvoiceModel
    private var editorModel: InvoiceEditorModel

    init (model: InvoiceModel) {
        self.invoiceModel = model
        self.editorModel = model.invoiceEditorModel
    }

    var body: some View {

        let _ = Self._printChanges()
        
        NavigationView {
            ScrollView {
                InvoiceEditorView(model: editorModel, onTapAddCompany: {
                    self.companiesStore.isShowingNewCompanySheet = true
                })
            }
            .navigationBarTitle("Invoice editor", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
//                        dismiss()
                        invoiceModel.dismissEditor()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        invoiceModel.save()
                        invoiceModel.dismissEditor()
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
