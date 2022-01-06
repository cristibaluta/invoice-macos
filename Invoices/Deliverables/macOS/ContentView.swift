//
//  ContentView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//
import Foundation
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: ContentStore
    
    init (store: ContentStore) {
        self.store = store
    }
    
    var body: some View {
        
        switch store.viewState {
            case .noProjects:
                NoProjectsView(store: store)
                .padding(40)
                
            case .noInvoices:
                NoInvoicesView(store: store)
                .padding(40)
                
            case .newInvoice(let invoiceStore):
                NewInvoiceView(store: invoiceStore) {
                    store.viewState = .invoice(invoiceStore)
                }
                .padding(40)
            
            case .charts(let priceChart, let rateChart):
                ChartsView(store: store, priceChartConfig: priceChart, rateChartConfig: rateChart)
                .padding(40)
                
            case .invoice(let invoiceStore):
                InvoiceView(store: invoiceStore) { data in
                    // Merge invoice data by keeping reports
                    let reports = store.reportStore?.data.reports ?? []
                    store.reportStore?.data = data
                    store.reportStore?.data.reports = reports
                    store.reportStore?.calculate()
                }
                .modifier(Toolbar(store: store))
                
            case .deleteInvoice(let invoice):
                DeleteConfirmationView(store: store, invoice: invoice)
                .padding(40)
            
            case .company(let companyDetails):
                NewCompanyView(store: CompaniesStore(data: companyDetails), callback: {
                    store.viewState = .noInvoices
                })
                .padding(40)
                
            case .report(let reportStore):
                ReportView(store: reportStore).frame(width: 920)
                .modifier(Toolbar(store: store))
                
            case .error(let title, let message):
                VStack(alignment: .center) {
                    Text(title).bold()
                    Text(message)
                }
                .padding(40)
        }
    }
}
