//
//  ReportEditorColumn.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.01.2024.
//

import Foundation
import SwiftUI
import Combine

struct ReportEditorColumn: View {

    var invoiceModel: InvoiceModel
    var editorViewModel: ReportEditorModel

    private let columns = [
        GridItem(.adaptive(minimum: 160))
    ]

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

            ReportEditorView(viewModel: editorViewModel)

//            Button("Save") {
//                invoiceModel.save()
//            }
        }
        .padding(20)
    }

}

