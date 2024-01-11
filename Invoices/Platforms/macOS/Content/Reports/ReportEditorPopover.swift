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
    @ObservedObject private var state: ContentData
    private let reportEditorState: ReportEditorState

    init (state: ContentData) {
        self.state = state
        self.reportEditorState = state.reportEditorState
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
                        state.reportEditorState.openCsv(at: url)
                    }
                }
            }

            Divider()

            ReportEditor(state: state.reportEditorState)
            
            Button("Save") {
                state.save()
                self.dismiss.callAsFunction()
            }
        }
        .padding(20)
    }

}
