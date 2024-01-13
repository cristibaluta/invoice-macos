//
//  SettingsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 12.01.2024.
//

import Foundation
import SwiftUI

struct SettingsWindow: View {

    @EnvironmentObject var setingsData: SetingsStore

    var body: some View {
        VStack{
            Text("Settings view")
        }
        .frame(width: 500, height: 500)
    }
}
