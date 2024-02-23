//
//  ContentView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//
import Foundation
import SwiftUI
import Combine

struct ContentColumn: View {

    @EnvironmentObject private var mainWindowState: MainWindowState
    @EnvironmentObject private var mainStore: MainStore

    var body: some View {

        let _ = Self._printChanges()

        switch mainWindowState.contentType {
            case .noProjects:
                NewProjectView { newProjectName in
                    mainStore.projectsStore.createProject(named: newProjectName)
                }

            case .noInvoices:
                NoInvoicesView {
                    mainStore.projectsStore.invoicesStore?.createNextInvoiceInProject()
                }

            case .newInvoice(let invoiceModel):
                NewInvoiceView(viewModel: invoiceModel.invoiceEditorModel)
                .padding(40)

            case .deleteInvoice(let invoice):
                DeleteConfirmationColumn(invoice: invoice)

            case .charts(let chartsViewModel):
                ChartsView(viewModel: chartsViewModel)
                .padding(40)

            case .invoice(let invoiceModel):
                InvoicePreviewColumn(invoiceModel: invoiceModel)
                
            case .invoiceEditor(let invoiceModel):
                InvoiceEditorColumn(editorModel: invoiceModel.invoiceEditorModel)
                .padding(10)
                .modifier(Toolbar(invoiceModel: invoiceModel))

            case .report(let invoiceModel):
                InvoicePreviewColumn(invoiceModel: invoiceModel)

            case .reportEditor(let invoiceModel):
                ReportEditorColumn(invoiceModel: invoiceModel, editorViewModel: invoiceModel.reportEditorModel)
                .padding(10)
                .modifier(Toolbar(invoiceModel: invoiceModel))

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
