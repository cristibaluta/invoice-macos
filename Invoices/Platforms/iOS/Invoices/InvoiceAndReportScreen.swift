//
//  InvoiceView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 08.01.2022.
//

import SwiftUI

class InvoiceAndReportScreenState: ObservableObject {

    @Published var html = ""
    var invoiceReportState: InvoiceAndReportState {
        didSet {
            self.html = invoiceReportState.html
        }
    }
    var invoice: Invoice

    init(invoice: Invoice, invoiceReportState: InvoiceAndReportState) {
        print(">>>>>> init InvoiceAndReportScreenState")
        self.invoice = invoice
        self.invoiceReportState = invoiceReportState
    }
}

struct InvoiceAndReportScreen: View {

    @EnvironmentObject var invoicesState: InvoicesState
    @ObservedObject var state: InvoiceAndReportScreenState
    @State private var isShowingEditInvoiceSheet = false

    
    var body: some View {

        let _ = Self._printChanges()

        GeometryReader { context in
            ScrollView {
                HtmlViewer(htmlString: state.html) { printingData in
                    state.invoiceReportState.pdfData = printingData
                }
                .frame(width: context.size.width,
                       height: context.size.width * HtmlViewer.size.height / HtmlViewer.size.width)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Type", selection: $state.invoiceReportState.contentType) {
                    Text("Invoice").tag(ContentType.invoice)
                    Text("Reports").tag(ContentType.report)
                }
                .frame(width: 150)
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: state.invoiceReportState.contentType) { newValue in
                    state.invoiceReportState.contentType = newValue
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditInvoiceSheet = true
                }
                .sheet(isPresented: $isShowingEditInvoiceSheet) {
                    if state.invoiceReportState.contentType == .invoice {
                        InvoiceEditorSheet(data: state.invoiceReportState.data) { updatedData in
                            print("invoice is udated")
                            state.invoiceReportState.data = updatedData
                            state.invoiceReportState.calculate()
                            state.html = state.invoiceReportState.html
                        }
                    } else {
                        ReportEditorSheet(data: state.invoiceReportState.data) { updatedData in
                            print("report is udated")
                        }
                    }
                }
            }
        }
        .onAppear() {
            _ = invoicesState.loadInvoice(state.invoice)
            .sink {
                $0.calculate()
                self.state.invoiceReportState = $0
            }
        }

    }

}
