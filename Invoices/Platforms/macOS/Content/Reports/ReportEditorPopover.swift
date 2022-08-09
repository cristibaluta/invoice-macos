//
//  ReportEditorPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import SwiftUI
import Combine

struct ReportEditorPopover: View {

//    @ObservedObject var state: ReportState
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]

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
            Button("Import worklogs (.csv)") {
                let panel = NSOpenPanel()
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                panel.allowsMultipleSelection = false
                //panel.allowedContentTypes = ["csv"]
                if panel.runModal() == .OK {
                    if let url = panel.urls.first {
                        state.reportState.openCsv(at: url)
                    }
                }
            }

            Divider()

            ReportEditor(state: state.reportState) { newData in
                state.data = newData
                state.calculate()
                self.onChange(newData)
            }
            
            Button("Save") {
                state.save()
                self.dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}
