//
//  ContentView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//
import Foundation
import SwiftUI
import Combine
import BarChart
import RCPreferences

enum ViewType {
    case noProjects
    case noInvoices
    case charts(ChartConfiguration, ChartConfiguration, Decimal)
    case newInvoice(InvoiceAndReportState)
    case deleteInvoice(Invoice)
    case invoice(InvoiceAndReportState)
    case report(InvoiceAndReportState)
    case company(CompanyData)
    case error(String, String)
}

class ContentColumnState: ObservableObject {

    @Published var type: ViewType = .noProjects
    @Published var html = ""
    var invoiceReportState: InvoiceAndReportState?
    var chartCancellable: Cancellable?
    var newInvoiceCancellable: Cancellable?
    var htmlCancellable: Cancellable?

    init() {
        print(">>>>>> init ContentColumnState")
    }
}

struct ContentColumn: View {

    @EnvironmentObject private var contentColumnState: ContentColumnState
    @EnvironmentObject private var foldersState: FoldersState
    @EnvironmentObject private var companiesState: CompaniesState

    var body: some View {

        let _ = Self._printChanges()

        switch contentColumnState.type {
            case .noProjects:
                NewFolderView { newProjectName in
                    foldersState.createFolder(named: newProjectName) { proj in
                        self.foldersState.selectedFolder = proj
                    }
                }

            case .noInvoices:
                NoInvoicesView {

                }

            case .newInvoice(let invoiceReportState):
                NewInvoiceView(state: invoiceReportState.invoiceEditorState)
                .padding(40)

            case .deleteInvoice(let invoice):
                DeleteConfirmationColumn(invoice: invoice)

            case .charts(let priceChart, let rateChart, let total):
                ChartsView(state: ChartsViewState(total: total), priceChartConfig: priceChart, rateChartConfig: rateChart)
                .padding(40)

            case .invoice(let invoiceReportState), .report(let invoiceReportState):
                if let state = contentColumnState.invoiceReportState {
                    HtmlViewer(htmlString: state.html) { printingData in
                        state.pdfData = printingData
                    }
                    .frame(width: 920)
                    .padding(10)
                    .modifier(Toolbar(invoiceReportState: invoiceReportState))
                    .onAppear {
                        contentColumnState.htmlCancellable = invoiceReportState.htmlPublisher.sink { html in
                            contentColumnState.html = html
                        }
                    }
                }

            case .company(let companyData):
                CompanyColumn(data: companyData)

            case .error(let title, let message):
                VStack(alignment: .center) {
                    Text(title).bold()
                    Text(message)
                }
                .padding(40)
        }
        
    }

}
