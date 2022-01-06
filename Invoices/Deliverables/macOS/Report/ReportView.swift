//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI

struct ReportView: View {
    
    @ObservedObject var store: ReportStore
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]
    
    init (store: ReportStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                #if os(iOS)
                    
                #else
                Button("Import CSV worklogs") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowsMultipleSelection = false
                    //                    panel.allowedContentTypes = ["csv"]
                    if panel.runModal() == .OK {
                        if let url = panel.urls.first {
                            store.openCsv(at: url)
                        }
                    }
                }
                #endif
                Button("Edit") {
                    store.showingPopover = true
                }
                .popover(isPresented: $store.showingPopover) {
                    VStack {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(0..<store.allProjects.count) { i in
                                    Toggle(store.allProjects[i].name, isOn: $store.allProjects[i].isOn)
                                    .onChange(of: store.allProjects[i].isOn) { val in
                                        store.updateReports()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 50)
                        .padding(10)
                        
                        Divider()
                        List(self.store.reports) { report in
                            ReportRowView(report: report) { newReport in
                                store.updateReport(newReport)
                            }
                        }                        
                    }
                    .frame(width: 600, height: 600)
                }
            }
            .frame(height: 36, alignment: .leading)
            
            HtmlView(htmlString: store.html) { printingData in
                store.printingData = printingData
            }
            .padding(10)
        }
    }
}
