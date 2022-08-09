//
//  SavePopover.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.08.2022.
//

import SwiftUI

struct SavePopover: View {

    @ObservedObject var state: InvoiceAndReportState

    var body: some View {
        VStack {
            switch state.contentType {
                case .invoice:
                    Text("Export Invoice to file")
                    Divider()
                    HStack {
                        Button("pdf") {
                            state.export(isPdf: true)
                        }
                        Button("html") {
                            state.export(isPdf: false)
                        }
                    }
                case .report:
                    Text("Export Report to file")
                    Divider()
                    HStack {
                        Button("pdf") {
                            state.export(isPdf: true)
                        }
                        Button("html") {
                            state.export(isPdf: false)
                        }
                    }
            }
        }
    }
}
