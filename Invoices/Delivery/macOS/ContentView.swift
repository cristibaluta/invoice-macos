//
//  ContentView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//
import Foundation
import SwiftUI
import BarChart

struct ContentView: View {
    
    @ObservedObject var store: ContentStore
    @State var editor: Int = 0
    @State private var showingAlert = false
    
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
            
            // Invoice and reports
            if store.currentInvoiceStore != nil {
                VStack {
                    switch store.section {
                        case 0:
                            if let invoiceStore = store.currentInvoiceStore {
                                InvoiceView(store: invoiceStore) { data in
                                    // Merge invoice data by keeping reports
                                    let reports = store.currentReportStore?.data.reports ?? []
                                    store.currentReportStore?.data = data
                                    store.currentReportStore?.data.reports = reports
                                    store.currentReportStore?.calculate()
                                }
                            }
                        case 1:
                            if let reportStore = store.currentReportStore {
                                ReportView(store: reportStore).frame(width: 920)
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
                        .help("Use data from the last invoice to create a new one.")
                        Button("Open") {
                            openProject()
                        }
                        .help("Chose a different location for your invoices.")
                        Divider()
                    }
                    ToolbarItem(placement: .principal) {
                        Picker("Section", selection: $editor) {
                            Text("Invoice").tag(0)
                            Text("Report").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: editor) { tag in
                            store.showSection(tag)
                        }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Spacer()
                        Button("Save") {
                            store.save()
                            showingAlert = true
                        }
                        .help("Save current data to json and pdf.")
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Save success"),
                                message: Text("Your pdf is saved in directory. You can right click on any invoice name to view it in Finder."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
            }
            else if let errorMessage = store.errorMessage {
                VStack(alignment: .center) {
                    Text(errorMessage.0).bold()
                    Text(errorMessage.1)
                }.padding(20)
            }
            else if store.hasFolderSelected {
                VStack(alignment: .center) {
                    
                    if store.chartEntries.isEmpty {
                        Text("No invoices created yet.")
                    } else {
                        Text("Invoice amount")
                        BarChartView(config: store.chartConfig)
                            .onAppear() {
                                store.chartConfig.data.color = .red
                                store.chartConfig.xAxis.labelsColor = .gray
                                store.chartConfig.xAxis.ticksColor = .gray
                                store.chartConfig.labelsCTFont = CTFontCreateWithName(("SFProText-Regular" as CFString), 10, nil)
                                store.chartConfig.xAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                                store.chartConfig.yAxis.labelsColor = .gray
                                store.chartConfig.yAxis.ticksColor = .gray
                                store.chartConfig.yAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                                store.chartConfig.yAxis.minTicksSpacing = 30.0
                                store.chartConfig.yAxis.formatter = { (value, decimals) in
                                    let format = value == 0 ? "" : "RON"
                                    return String(format: "%.\(decimals)f \(format)", value)
                                }
                            }
                            .frame(height: 300)
                            .padding(20)
                            .animation(.easeInOut)
                        
                        Spacer().frame(height: 30)
                        Text("Rate")
                        BarChartView(config: store.rateChartConfig)
                            .onAppear() {
                                store.rateChartConfig.data.color = .orange
                                store.rateChartConfig.xAxis.labelsColor = .gray
                                store.rateChartConfig.xAxis.ticksColor = .gray
                                store.rateChartConfig.labelsCTFont = CTFontCreateWithName(("SFProText-Regular" as CFString), 10, nil)
                                store.rateChartConfig.xAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                                store.rateChartConfig.yAxis.labelsColor = .gray
                                store.rateChartConfig.yAxis.ticksColor = .gray
                                store.rateChartConfig.yAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                                store.rateChartConfig.yAxis.minTicksSpacing = 30.0
                                store.rateChartConfig.yAxis.formatter = { (value, decimals) in
                                    let format = value == 0 ? "" : "€"
                                    return String(format: "%.\(decimals)f \(format)", value)
                                }
                            }
                            .frame(height: 150)
                            .padding(20)
                            .animation(.easeInOut)
                    }
                }
                .padding(20)
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button("New invoice") {
                            store.generateNewInvoice()
                        }
                        .help("Use data from the last invoice to create a new one.")
                        Button("Open") {
                            openProject()
                        }
                        Divider()
                    }
                }
            }
            else {
                VStack(alignment: .center) {
                    Text("Create your first series of invoices, select a directory!")
                    Button("Select") {
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
