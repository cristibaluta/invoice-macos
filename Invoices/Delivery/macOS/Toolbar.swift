//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI

struct Toolbar: ViewModifier {
    
    @ObservedObject var store: ContentStore
    @State private var showingExportPopover = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Section", selection: $store.section) {
                        Text("Invoice").tag(0)
                        Text("Report").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: store.section) { tag in
                        store.showSection(tag)
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Spacer()
                    Button("Save") {
                        store.save()
                    }
                    .help("Save current data to json")
                    
                    Button(action: {
                        showingExportPopover = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .popover(isPresented: $showingExportPopover) {
                        VStack {
                            switch store.section {
                                case 0:
                                    Text("Export current Invoice to file")
                                    Divider()
                                    HStack {
                                        Button("pdf") {
                                            store.exportInvoice(isPdf: true)
                                        }
                                        Button("html") {
                                            store.exportInvoice(isPdf: false)
                                        }
                                    }
                                case 1:
                                    Text("Export current Report to file")
                                    Divider()
                                    HStack {
                                        Button("pdf") {
                                            store.exportReport(isPdf: true)
                                        }
                                        Button("html") {
                                            store.exportReport(isPdf: false)
                                        }
                                    }
                                default:
                                    Spacer()
                            }
                        }
                        .padding(20)
                    }
                }
            }
    }
}
