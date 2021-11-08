//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI

struct ReportView: View {
    
    @ObservedObject var store: ReportStore
    @State private var showingPopover = false
    
    init (store: ReportStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button("Open CSV") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowsMultipleSelection = false
                    //                panel.allowedContentTypes = [UTType]
                    if panel.runModal() == .OK {
                        if let url = panel.urls.first {
                            store.openCsv(at: url)
                        }
                    }
                }
                Button("Edit") {
                    showingPopover = true
                }
                .popover(isPresented: $showingPopover) {
                    List(self.store.reports) { report in
                        ReportRowView(report: report) { newReport in
                            
                        }
                    }
                    .frame(width: 600, height: 500)
                }
            }
            
            HtmlView(htmlString: store.html) { printingData in
                store.printingData = printingData
            }
            .padding(10)
        }
    }
}
