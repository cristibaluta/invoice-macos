//
//  Toolbar.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.12.2021.
//

import SwiftUI

struct Toolbar: ViewModifier {

    @EnvironmentObject var mainViewState: MainViewState
    @ObservedObject var invoiceStore: InvoiceStore
    @ObservedObject var reportStore: ReportStore
    @State private var isShowingExportPopover = false
    
    func body (content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Section", selection: $mainViewState.segmentedControl) {
                    Text("Invoice").tag(SegmentedControlType.invoice)
                    Text("Report").tag(SegmentedControlType.report)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: mainViewState.segmentedControl) { tag in
//                    contentData.contentType = tag
//                    contentData.calculate()
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button("Edit \(mainViewState.segmentedControl == .invoice ? "invoice" : "report")") {
                    invoiceStore.isShowingEditorSheet = true
                }
                .popover(isPresented: $invoiceStore.isShowingEditorSheet) {
                    switch mainViewState.segmentedControl {
                        case .invoice:
                            InvoiceEditorPopover(state: invoiceStore)
                        case .report:
                            ReportEditorPopover(store: reportStore)
                            .frame(width: 500, height: 600)
                    }
                }
                
                Button(action: {
                    isShowingExportPopover = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .popover(isPresented: $isShowingExportPopover) {
                    ExportPopover(state: invoiceStore)
                    .padding(20)
                }
            }
        }

    }

}
