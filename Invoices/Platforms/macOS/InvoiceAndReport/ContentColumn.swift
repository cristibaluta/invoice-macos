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
    @EnvironmentObject private var mainStore: MainStore

    var body: some View {

        let _ = Self._printChanges()

        switch mainViewState.contentType {
            case .noProjects:
                NewProjectView { newProjectName in
                    mainStore.projectsStore.createProject(named: newProjectName)
                }

            case .noInvoices:
                NoInvoicesView {
                    mainStore.projectsStore.invoicesStore?.createNextInvoiceInProject()
                }

            case .newInvoice(let invoiceStore):
                NewInvoiceView(viewModel: invoiceStore.invoiceEditorViewModel)
                .padding(40)

            case .deleteInvoice(let invoice):
                DeleteConfirmationColumn(invoice: invoice)

            case .charts(let chartsViewModel):
                ChartsView(viewModel: chartsViewModel)
                .padding(40)

            case .invoice(let invoiceStore):
                HtmlViewer(htmlString: mainViewState.html) { printingData in
                    invoiceStore.pdfData = printingData
                }
                .frame(width: 920)
                .padding(10)
                .modifier(Toolbar(invoiceStore: invoiceStore))
                .task(id: invoiceStore.id) {
                    // Use task because onAppear will not be called when store changes
                    mainViewState.htmlCancellable = invoiceStore.htmlDidChangePublisher.sink { html in
                        mainViewState.html = html
                    }
                    invoiceStore.buildHtml()
                }
                
            case .invoiceEditor(let invoiceStore):
                InvoiceEditorColumn(editorViewModel: invoiceStore.invoiceEditorViewModel)
                .padding(10)
                .modifier(Toolbar(invoiceStore: invoiceStore))

            case .report(let invoiceStore):
                HtmlViewer(htmlString: mainViewState.html) { printingData in
                    invoiceStore.pdfData = printingData
                }
                .frame(width: 920)
                .padding(10)
                .modifier(Toolbar(invoiceStore: invoiceStore))
                .task(id: invoiceStore.id) {
                    // Use task because onAppear will not be called when store changes
                    mainViewState.htmlCancellable = invoiceStore.htmlDidChangePublisher.sink { html in
                        mainViewState.html = html
                    }
                    invoiceStore.buildHtml()
                }

            case .reportEditor(let invoiceStore):
                ReportEditorColumn(invoiceStore: invoiceStore, editorViewModel: invoiceStore.reportEditorViewModel)
                .padding(10)
                .modifier(Toolbar(invoiceStore: invoiceStore))

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
