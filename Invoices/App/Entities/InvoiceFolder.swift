//
//  InvoiceFolder.swift
//  Invoices
//
//  Created by Cristian Baluta on 10.11.2021.
//

import Foundation

struct InvoiceFolder: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var invoiceNr: String
    var name: String
}
