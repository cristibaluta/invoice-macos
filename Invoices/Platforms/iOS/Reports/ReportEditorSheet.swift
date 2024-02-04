//
//  ReportEditorSheet.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 22.07.2022.
//

import Foundation
import SwiftUI

struct ReportEditorSheet: View {

    @Environment(\.dismiss) var dismiss
//    private var state: ReportEditorViewModel
    private let onChange: (InvoiceData) -> Void

    init (data: InvoiceData, onChange: @escaping (InvoiceData) -> Void) {
        self.onChange = onChange
//        self.state = ReportEditorViewModel(data: data)
    }

    var body: some View {

        let _ = Self._printChanges()

        NavigationView {
            ScrollView {
//                ReportEditor(state: state, onChange: { newData in
//                    self.state.data = newData
//                    self.onChange(newData)
//                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
//                        self.state.dismissInvoiceEditor()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit invoice").font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
//                        onChange(state.data)
//                        self.dismiss.callAsFunction()
                    }
                }
            }
//            .sheet(isPresented: $companiesData.isShowingNewCompanySheet) {
//                NewCompanySheet()
//            }
        }
    }

}

