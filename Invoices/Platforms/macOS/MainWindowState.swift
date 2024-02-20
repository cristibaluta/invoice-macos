//
//  mainWindowState.swift
//  Invoices
//
//  Created by Cristian Baluta on 12.01.2024.
//

import Foundation
import Combine

enum ContentViewType {
    case noProjects
    case noInvoices
    case charts(ChartsViewModel)
    case newInvoice(InvoiceModel)
    case deleteInvoice(Invoice)
    case invoice(InvoiceModel)
    case invoiceEditor(InvoiceModel)
    case report(InvoiceModel)
    case reportEditor(InvoiceModel)
    case company(CompanyData)
    case error(String, String)
}

class MainWindowState: ObservableObject {

    @Published var contentType: ContentViewType = .noProjects

}
