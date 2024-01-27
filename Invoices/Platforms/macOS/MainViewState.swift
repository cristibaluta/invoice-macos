//
//  MainViewState.swift
//  Invoices
//
//  Created by Cristian Baluta on 12.01.2024.
//

import Foundation
import SwiftUI
import Combine
import BarChart

enum ContentViewType {
    case noProjects
    case noInvoices
    case charts(ChartsViewModel)
    case newInvoice(InvoiceStore)
    case deleteInvoice(Invoice)
    case invoice(InvoiceStore)
    case invoiceEditor(InvoiceStore)
    case report(InvoiceStore)
    case reportEditor(InvoiceStore)
    case company(CompanyData)
    case error(String, String)
}

class MainViewState: ObservableObject {

    @Published var contentType: ContentViewType = .noProjects
    @Published var editorType: EditorType = .invoice
    @Published var isEditing = false
    @Published var html = ""
    @Published var pdfdata: Data? {
        didSet{
            print(">>>>>>>> pdfdata did set")
        }
    }

    var chartCancellable: Cancellable?
//    var newInvoiceCancellable: Cancellable?
    var htmlCancellable: Cancellable?
    
    init() {
        print(">>>>>> init ContentColumnState")
    }
}
