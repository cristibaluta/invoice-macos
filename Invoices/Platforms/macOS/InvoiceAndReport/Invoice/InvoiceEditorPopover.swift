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
    var invoiceStore: InvoiceStore
    var editorViewModel: InvoiceEditorViewModel

    var body: some View {

        let _ = Self._printChanges()

        VStack {
            InvoiceEditor(viewModel: editorViewModel, onTapAddCompany: {
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
