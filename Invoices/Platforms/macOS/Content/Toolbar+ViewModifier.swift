//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI

struct Toolbar: ViewModifier {

    @EnvironmentObject var contentColumnState: ContentColumnState
    @ObservedObject var contentData: ContentData
    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Section", selection: $contentData.contentType) {
                    Text("Invoice").tag(ContentType.invoice)
                    Text("Report").tag(ContentType.report)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: contentData.contentType) { tag in
                    contentData.contentType = tag
                    contentData.calculate()
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Edit \(contentData.contentType == .invoice ? "invoice" : "report")") {
                    contentData.isShowingEditorSheet = true
                }
                .popover(isPresented: $contentData.isShowingEditorSheet) {
                    switch contentData.contentType {
                        case .invoice:
                            InvoiceEditorPopover(state: contentData)
                        case .report:
                            ReportEditorPopover(state: contentData)
                            .frame(width: 500, height: 600)
                    }
                }
                
                Button(action: {
                    isShowingExportPopover = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .popover(isPresented: $isShowingExportPopover) {
                    SavePopover(state: contentData)
                    .padding(20)
                }
            }
        }

    }

}
