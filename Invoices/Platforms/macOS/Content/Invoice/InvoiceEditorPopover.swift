//
//  InvoiceEditorPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 25.07.2022.
//

import SwiftUI

struct InvoiceEditorPopover: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var companiesData: CompaniesData
    @ObservedObject private var state: ContentData

    private let invoiceEditorState: InvoiceEditorState

    init (state: ContentData) {
        self.state = state
        self.invoiceEditorState = state.invoiceEditorState
    }

    var body: some View {

        let _ = Self._printChanges()

        VStack {
            InvoiceEditor(state: invoiceEditorState, onTapAddCompany: {
                self.companiesData.isShowingNewCompanySheet = true
            })
            Button("Save") {
                state.save()
                self.dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}