//
//  InvoicesConfig.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.01.2024.
//

import Foundation
import SwiftUI
import RCPreferences

#if os(macOS)
let appFont = Font.system(size: 12)
#else
let appFont = Font.system(.body)
#endif

enum UserPreferences: String, RCPreferencesProtocol {

    case lastProject = "lastProject"

    func defaultValue() -> Any {
        switch self {
            case .lastProject: return ""
        }
    }
}