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
    case charts(ChartConfiguration, ChartConfiguration, Decimal)
    case newInvoice(InvoiceStore)
    case deleteInvoice(Invoice)
    case invoice(InvoiceStore)
    case report(InvoiceStore)
    case company(CompanyData)
    case error(String, String)
}

class MainViewState: ObservableObject {

    @Published var type: ContentViewType = .noProjects
    @Published var segmentedControl: SegmentedControlType = .invoice
    @Published var html = ""

    var invoiceStore: InvoiceStore?
    var reportStore: InvoiceStore?
    var chartCancellable: Cancellable?
    var newInvoiceCancellable: Cancellable?
    var htmlCancellable: Cancellable?

    @State private var selectedInvoice: Invoice? {
        didSet {
//            _ = invoicesData.loadInvoice(selectedInvoice!)
//                .sink { contentData in
//                    mainViewState.contentData = contentData
//                    mainViewState.type = .invoice(contentData)
//                    contentData.calculate()
//                }
        }
    }
    
    init() {
        print(">>>>>> init ContentColumnState")
    }
}
