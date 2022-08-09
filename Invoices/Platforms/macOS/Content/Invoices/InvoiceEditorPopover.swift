//
//  InvoiceEditorPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 25.07.2022.
//

import SwiftUI

struct InvoiceEditorPopover: View {

    @EnvironmentObject var companiesState: CompaniesState
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var state: InvoiceAndReportState
    private let onChange: (InvoiceData) -> Void
    private let invoiceEditorState: InvoiceEditorState

    init (state: InvoiceAndReportState, onChange: @escaping (InvoiceData) -> Void) {
        self.state = state
        self.onChange = onChange
        self.invoiceEditorState = state.invoiceEditorState
    }

    var body: some View {

        let _ = Self._printChanges()

        VStack {
            InvoiceEditor(state: invoiceEditorState, onChange: { newData in
                state.data = newData
                state.calculate()
                self.onChange(newData)
            }, onTapAddCompany: {
                self.companiesState.isShowingNewCompanySheet = true
            })
            Button("Save") {
                state.save()
                self.dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}
