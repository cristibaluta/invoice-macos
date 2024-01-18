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

struct ContentColumn: View {

    @EnvironmentObject private var mainViewState: MainViewState
    @EnvironmentObject private var projectsStore: ProjectsStore
    @EnvironmentObject private var companiesStore: CompaniesStore

    var body: some View {

        let _ = Self._printChanges()

        switch mainViewState.contentType {
            case .noProjects:
                NewProjectView { newProjectName in
                    projectsStore.createProject(named: newProjectName) { proj in
                        self.projectsStore.selectedProject = proj
                    }
                }

            case .noInvoices:
                NoInvoicesView {

                }

            case .newInvoice(let invoiceStore):
                NewInvoiceView(viewModel: invoiceStore.createInvoiceEditor())
                .padding(40)

            case .deleteInvoice(let invoice):
                DeleteConfirmationColumn(invoice: invoice)

            case .charts(let priceChart, let rateChart, let total):
                ChartsView(state: ChartsViewState(total: total), priceChartConfig: priceChart, rateChartConfig: rateChart)
                .padding(40)

            case .invoice(let store):
                HtmlViewer(htmlString: mainViewState.html, pdfData: mainViewState.pdfdata) { printingData in
                    store.pdfData = printingData
                }
                .frame(width: 920)
                .padding(10)
                .modifier(Toolbar(invoiceStore: store, isEditing: false))
                .task(id: store.id) {
                    // Use task because onAppear will not be called when store changes
                    mainViewState.htmlCancellable = store.htmlDidChangePublisher.sink { html in
                        mainViewState.html = html
                    }
                    store.buildHtml()
                }
                
            case .invoiceEditor(let store):
                InvoiceEditorColumn(editorViewModel: store.createInvoiceEditor())
                .padding(10)
                .modifier(Toolbar(invoiceStore: store, isEditing: true))

            case .report(let store):
                HtmlViewer(htmlString: mainViewState.html, pdfData: mainViewState.pdfdata) { printingData in
                    store.pdfData = printingData
                }
                .frame(width: 920)
                .padding(10)
                .modifier(Toolbar(invoiceStore: store, isEditing: false))
                .task(id: store.id) {
                    // Use task because onAppear will not be called when store changes
                    mainViewState.htmlCancellable = store.htmlDidChangePublisher.sink { html in
                        mainViewState.html = html
                    }
                    store.buildHtml()
                }

            case .reportEditor(let store):
                ReportEditorColumn(invoiceStore: store, editorViewModel: store.createReportEditor())
                .padding(10)
                .modifier(Toolbar(invoiceStore: store, isEditing: true))

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
