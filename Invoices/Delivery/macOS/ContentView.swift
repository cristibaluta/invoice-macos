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
    @State private var showingExportPopover = false
    @State private var showingDeleteProject = false
    @State private var showingDeleteInvoice = false
    
    init (store: ContentStore) {
        self.store = store
    }
    
    var body: some View {
        NavigationView {
            // Drawer
            switch store.drawerState {
                case .noProjects:
                    Text("No projects!")
                case .projects(_), .invoices(_):
                    VStack {
                        List(store.projects, id: \.self, selection: $store.selectedProject) { project in
                            Text(project.name)
                            .onTapGesture {
                                store.loadProject(project)
                            }
                            .contextMenu {
                                Button(action: {
                                    store.showInFinder(project)
                                }) {
                                    Text("Show in Finder")
                                }
//                                Button(action: {
//                                    showingDeleteProject = true
//                                }) {
//                                    Text("Delete")
//                                }
                            }
//                            .alert(isPresented: $showingDeleteProject) {
//                                Alert(title: Text("Confirm delete"),
//                                      message: Text("Are you sure you want to delete project '\(project.name)'?"),
//                                      primaryButton: .default(Text("Yes")) {showingDeleteProject = false},
//                                      secondaryButton: .cancel() {showingDeleteProject = false}
//                                )
//                            }
                        }
                        .frame(height: 100)
                        
                        Divider()
                        
                        if self.store.invoices.isEmpty {
                            Text("No invoices!")
                        } else {
                            Button("+") {
                                store.generateNewInvoice()
                            }
                            .help("Create a new invoice using data from the last invoice.")
                        }
                        
                        List(self.store.invoices, id: \.self, selection: $store.selectedInvoice) { invoice in
                            Text(invoice.name)
                            .onTapGesture {
                                store.loadInvoice(invoice)
                            }
                            .contextMenu {
                                Button(action: {
                                    store.showInFinder(invoice)
                                }) {
                                    Text("Show in Finder")
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            Spacer()
                            Button("+") {
                                store.viewState = .noProjects
                            }
                            .help("Create a new project.")
                        }
                    }
            }
            
            switch store.viewState {
                case .noProjects:
                    VStack(alignment: .center) {
                        Text("Create a new project!").bold()
                        Text("In a project you can keep invoices from the same series. Each new invoice will use data from the previous invoice and the number will increase automatically.")
                        HStack {
                            TextField("Project name", text: $store.projectName).frame(width: 160)
                            Button("Create") {
                                store.createProject(store.projectName)
                            }
                        }
                    }
                    
                case .noInvoices:
                    VStack(alignment: .center) {
                        Text("Create your first invoice!").bold()
                        Text("Each project has its own templates and can be edited from Finder. You can right click on any project or invoice to view the files in Finder.")
                        Button("New invoice") {
                            store.generateNewInvoice()
                        }
                    }
                    
                case .charts(let priceChart, let rateChart):
                    ChartsView(store: store, priceChartConfig: priceChart, rateChartConfig: rateChart)
                    
                case .invoice(let invoiceStore):
                    InvoiceView(store: invoiceStore) { data in
                        // Merge invoice data by keeping reports
                        let reports = store.reportStore?.data.reports ?? []
                        store.reportStore?.data = data
                        store.reportStore?.data.reports = reports
                        store.reportStore?.calculate()
                    }
                    .modifier(Toolbar(store: store))
                    
                case .report(let reportStore):
                    ReportView(store: reportStore).frame(width: 920)
                    .modifier(Toolbar(store: store))
                    
                case .error(let title, let message):
                    VStack(alignment: .center) {
                        Text(title).bold()
                        Text(message)
                    }
                    .padding(20)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 600, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle(store.invoiceName)
    }
}
