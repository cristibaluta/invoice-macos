//
//  Report.swift
//  Invoices
//
//  Created by Cristian Baluta on 24.11.2021.
//

import Foundation

struct Report: Identifiable {
    var id = UUID()
    var project_name: String
    var group: String
    var description: String
    var duration: Decimal
}

struct ReportProject: Identifiable {
    var id = UUID()
    var name: String
    var isOn: Bool
}
