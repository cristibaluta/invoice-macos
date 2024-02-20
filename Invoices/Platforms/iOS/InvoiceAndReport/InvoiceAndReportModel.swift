//
//  InvoiceAndReportModel.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 20.02.2024.
//

import Foundation
import SwiftUI
import Combine

class InvoiceAndReportModel: ObservableObject {

    @Published var html = ""
    @Published var editorType: EditorType = .invoice {
        didSet {
            invoiceStore?.editorType = editorType
        }
    }
    var invoiceStore: InvoiceStore? {
        didSet {
            html = invoiceStore?.html ?? ""
            cancellable?.cancel()
            cancellable = invoiceStore?.htmlDidChangePublisher.sink { newHtml in
                self.html = newHtml
            }
        }
    }
    var invoice: Invoice
    private var cancellable: AnyCancellable?

    init(invoice: Invoice, invoiceStore: InvoiceStore?) {
        print(">>>>>> init InvoiceAndReportModel")
        self.invoice = invoice
        self.invoiceStore = invoiceStore
    }

    deinit {
        print("<<<<<< deinit InvoiceAndReportModel")
    }
}
