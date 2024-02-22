//
//  InvoiceEditorPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 25.07.2022.
//

import SwiftUI

struct InvoiceEditorPopover: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var companiesStore: CompaniesStore
    var invoiceModel: InvoiceModel
    var editorModel: InvoiceEditorModel

    var body: some View {

        let _ = Self._printChanges()

        VStack {
            InvoiceEditorView(model: editorModel, onTapAddCompany: {
                self.companiesStore.isShowingNewCompanySheet = true
            })
            Button("Save") {
                invoiceModel.save()
                dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}
