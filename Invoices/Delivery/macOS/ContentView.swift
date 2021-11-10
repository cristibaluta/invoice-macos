//
//  ContentView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//
import Foundation
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: ContentStore
    @State var editor: Int = 0
    
    init (store: ContentStore) {
        self.store = store
    }
    
    var body: some View {
        NavigationView {
            // List of invoices
            List(self.store.invoices, id: \.self, selection: $store.selectKeeper) { invoice in
                Text(invoice.name)
                    .onTapGesture {
                        store.showInvoice(invoice)
                    }
                    .contextMenu {
                        Button(action: {
                            store.showInFinder(invoice)
                        }) {
                            Text("Show in Finder")
                        }
                    }
            }
            
            if store.currentInvoiceStore != nil {
                HStack {
                    switch store.section {
                        case 0:
                            if let invoiceStore = store.currentInvoiceStore {
                                InvoiceView(store: invoiceStore)
                                    .frame(width: 920)
                                if store.isEditing {
                                    InvoiceEditingView(store: InvoiceEditingStore(data: invoiceStore.data)) { data in
                                        store.currentInvoiceData = data
                                    }
                                    .frame(maxWidth: 220)
                                }
                            }
                        case 1:
                            if let reportStore = store.currentReportStore {
                                ReportView(store: reportStore)
                                    .frame(width: 920)
                            }
                        default:
                            Text("Invalid section")
                    }
                }
                .navigationTitle(store.invoiceName)
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button("New invoice") {
                            store.generateNewInvoice()
                        }
                        Button("Open project") {
                            openProject()
                        }
                        Divider()
                    }
                    ToolbarItem(placement: .principal) {
                        Picker("Section", selection: $editor) {
                            Text("Factura").tag(0)
                            Text("Anexa").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: editor) { tag in
                            store.showSection(tag)
                        }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Spacer()
                        if store.section == 0 {
                            Button("Edit") {
                                store.edit()
                            }
                        }
                        Button("Save") {
                            store.save()
                        }
                    }
                }
            } else if let errorMessage = store.errorMessage {
                VStack(alignment: .center) {
                    Text(errorMessage.0).bold()
                    Text(errorMessage.1)
                }.padding(20)
            } else if store.hasFolderSelected {
                VStack(alignment: .center) {
                    Text("Select an invoice from the left side or create a new one using data from the last invoice.")
                    Button("New Invoice") {
                        store.generateNewInvoice()
                    }
                }.padding(20)
            } else {
                VStack(alignment: .center) {
                    Text("Create your first project, select a directory for your invoices!")
                    Button("Create project") {
                        openProject()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 600, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func openProject() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Chose a destination directory for your invoices"
        if panel.runModal() == .OK {
            if let url = panel.urls.first {
                store.initProject(at: url)
                store.reloadData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: ContentStore())
    }
}
