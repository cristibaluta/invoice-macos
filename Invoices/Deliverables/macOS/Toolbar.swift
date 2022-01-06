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
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Section", selection: $store.section) {
                    Text("Invoice").tag(Section.invoice)
                    Text("Report").tag(Section.report)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: store.section) { tag in
                    store.showSection(tag)
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Save \(store.section == .invoice ? "invoice" : "report")") {
                    store.save()
                }
                
                Button(action: {
                    showingExportPopover = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .popover(isPresented: $showingExportPopover) {
                    VStack {
                        switch store.section {
                            case .invoice:
                                Text("Export Invoice to file")
                                Divider()
                                HStack {
                                    Button("pdf") {
                                        store.export(isPdf: true)
                                    }
                                    Button("html") {
                                        store.export(isPdf: false)
                                    }
                                }
                            case .report:
                                Text("Export Report to file")
                                Divider()
                                HStack {
                                    Button("pdf") {
                                        store.export(isPdf: true)
                                    }
                                    Button("html") {
                                        store.export(isPdf: false)
                                    }
                                }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}
