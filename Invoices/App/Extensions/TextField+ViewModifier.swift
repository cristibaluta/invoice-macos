//
//  TextField+ViewModifier.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.08.2022.
//

import Foundation
import SwiftUI

struct OutlineTextField: ViewModifier {

    func body (content: Content) -> some View {
        #if os(iOS)
        content
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 8.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 0.5)))
        #else
        content
        #endif
    }
}
