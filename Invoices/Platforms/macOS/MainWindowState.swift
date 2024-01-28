//
//  mainWindowState.swift
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

class MainWindowState: ObservableObject {

    @Published var contentType: ContentViewType = .noProjects
    
    init() {
        print(">>>>>> init ContentColumnState")
    }
}
