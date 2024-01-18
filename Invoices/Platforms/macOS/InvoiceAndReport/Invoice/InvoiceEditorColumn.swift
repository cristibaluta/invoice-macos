//
//  InvoiceEditorColumn.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import SwiftUI

struct InvoiceEditorColumn: View {

    @EnvironmentObject var companiesStore: CompaniesStore
    var editorViewModel: InvoiceEditorViewModel

    var body: some View {

        let _ = Self._printChanges()

        VStack {
            InvoiceEditor(viewModel: editorViewModel, onTapAddCompany: {
                self.companiesStore.isShowingNewCompanySheet = true
            })
        }
        .padding(20)
    }

}
