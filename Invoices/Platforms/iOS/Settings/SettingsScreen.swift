//
//  SettingsScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 19.02.2024.
//

import Foundation
import SwiftUI

struct SettingsScreen: View {

    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        List {
            Section("Files location") {
                ForEach($settingsStore.repositories) { $item in
                    SelectionCell(item: $item, selectedItem: $settingsStore.selection)
                        .onTapGesture {
                            if let ndx = settingsStore.repositories.firstIndex(where: { $0.id == settingsStore.selection }) {
                                settingsStore.repositories[ndx].isOn = false
                                settingsStore.setCurrentRepository(item.type)
                            }
                            settingsStore.selection = item.id
                            item.isOn = true
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings").font(.headline)
            }
        }
    }

}

struct SelectionCell: View {

    @Binding var item: RepositoryOption
    @Binding var selectedItem: RepositoryOption.ID?

    var body: some View {
        HStack {
            Text(item.type.name)
            Spacer()
            if item.id == selectedItem {
                Image(systemName: "checkmark").foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
    }

}
