//
//  InvoiceView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 08.01.2022.
//

import SwiftUI

class InvoiceAndReportScreenState: ObservableObject {

    @Published var html = ""
    var contentData: InvoiceStore {
        didSet {
            self.html = contentData.html
        }
    }
    var invoice: Invoice

    init(invoice: Invoice, contentData: InvoiceStore) {
        print(">>>>>> init InvoiceAndReportScreenState")
        self.invoice = invoice
        self.contentData = contentData
    }
}

struct InvoiceAndReportScreen: View {

    @EnvironmentObject var invoicesData: InvoicesStore
    @ObservedObject var state: InvoiceAndReportScreenState
    @State private var isShowingEditInvoiceSheet = false
    @State var data = WrappedData()

    
    var body: some View {

        let _ = Self._printChanges()

        GeometryReader { context in
            ScrollView {
                HtmlViewer(htmlString: state.html, wrappedPdfData: data)
                .frame(width: context.size.width,
                       height: context.size.width * HtmlViewer.size.height / HtmlViewer.size.width)
            }
        }
        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Picker("Type", selection: $state.contentData.contentType) {
//                    Text("Invoice").tag(EditorType.invoice)
//                    Text("Reports").tag(EditorType.report)
//                }
//                .frame(width: 150)
//                .pickerStyle(SegmentedPickerStyle())
//                .onChange(of: state.contentData.contentType) { newValue in
//                    state.contentData.contentType = newValue
//                }
//            }
//            ToolbarItem(placement: .primaryAction) {
//                Button("Edit") {
//                    isShowingEditInvoiceSheet = true
//                }
//                .sheet(isPresented: $isShowingEditInvoiceSheet) {
//                    if state.contentData.contentType == .invoice {
//                        InvoiceEditorSheet(data: state.contentData.data) { updatedData in
//                            print("invoice is udated")
//                            state.contentData.data = updatedData
//                            state.contentData.calculate()
//                            state.html = state.contentData.html
//                        }
//                    } else {
//                        ReportEditorSheet(data: state.contentData.data) { updatedData in
//                            print("report is udated")
//                        }
//                    }
//                }
//            }
        }
        .onAppear() {
            _ = invoicesData.loadInvoice(state.invoice)
            .sink {
//                $0.calculate()
                self.state.contentData = $0
            }
        }

    }

}