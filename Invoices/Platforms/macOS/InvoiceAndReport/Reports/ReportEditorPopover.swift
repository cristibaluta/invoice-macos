//
//  ReportEditorPopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import SwiftUI
import Combine

struct ReportEditorPopover: View {

    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]

    @Environment(\.dismiss) var dismiss
    var invoiceStore: InvoiceStore
    var editorViewModel: ReportEditorViewModel

//    init (store: ReportStore) {
//        self.store = store
//        self.reportEditorState = store.reportEditorState
//    }

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
                        editorViewModel.importCsv(at: url)
                    }
                }
            }

            Divider()

            ReportEditor(viewModel: editorViewModel)

            Button("Save") {
                invoiceStore.save()
                self.dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}