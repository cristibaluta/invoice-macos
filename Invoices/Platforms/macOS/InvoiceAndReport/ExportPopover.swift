//
//  SavePopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.08.2022.
//

import SwiftUI

struct ExportPopover: View {

    @EnvironmentObject var mainViewState: MainViewState
    @ObservedObject var state: InvoiceStore

    var body: some View {
        VStack {
            switch state.editorType {
                case .invoice:
                    Text("Export Invoice to file")
                    Divider()
                    HStack {
//                        Button("pdf") {
//                            state.export(isPdf: true)
//                        }
//                        Button("html") {
//                            state.export(isPdf: false)
//                        }
                    }
                case .report:
                    Text("Export Report to file")
                    Divider()
                    HStack {
//                        Button("pdf") {
//                            state.export(isPdf: true)
//                        }
//                        Button("html") {
//                            state.export(isPdf: false)
//                        }
                    }
            }
        }
    }
}
