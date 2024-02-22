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
    var invoiceStore: InvoiceModel
    var editorViewModel: InvoiceEditorModel

    var body: some View {

        let _ = Self._printChanges()

        VStack {
            InvoiceEditorView(viewModel: editorViewModel, onTapAddCompany: {
                self.companiesStore.isShowingNewCompanySheet = true
            })
            Button("Save") {
                invoiceStore.save()
                self.dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}
