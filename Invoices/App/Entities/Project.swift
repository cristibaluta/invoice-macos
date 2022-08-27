//
//  Project.swift
//  Invoices
//
//  Created by Cristian Baluta on 27.08.2022.
//

import Foundation

/// The project for which you are doing the reports
struct Project: Identifiable {
    var id = UUID()
    var name: String
    var isOn: Bool
}
