//
//  Keyboard+ViewModifier.swift
//  Invoices
//
//  Created by Cristian Baluta on 22.07.2022.
//

import Foundation
import SwiftUI

struct NumberKeyboard: ViewModifier {

    func body (content: Content) -> some View {
        #if os(iOS)
        content.keyboardType(.decimalPad)
        #else
        content
        #endif
    }
}
