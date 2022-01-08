//
//  ContentView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 04.01.2022.
//

import Foundation
import SwiftUI

struct WindowView: View {
    
    @ObservedObject var store: WindowStore
    @State var selection: Int?
    
    init (store: WindowStore) {
        self.store = store
    }
    
    var body: some View {
        TabView {
            NavigationView {
                switch store.sidebarState {
                    case .noProjects:
                        NoProjectsView(store: store) {
                            store.reloadProjects()
                        }
                    default:
                        ProjectsView(store: store)
                }
            }
            .tabItem { Label("Invoices", systemImage: "list.bullet") }
            .tag(0)
            //
            NavigationView {
                CompaniesView(store: CompaniesStore(data: nil))
            }
            .tabItem { Label("Companies", systemImage: "heart.fill") }
            .tag(1)
            //
            NavigationView {
                
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(2)
        }
    }
}

//                switch store.viewState {
//                    case .noProjects:
//                        NoProjectsView(store: store)
//                        .padding(40)
//
//                    case .noInvoices:
//                        NoInvoicesView(store: store)
//                        .padding(40)
//
//                    case .newInvoice(let invoiceStore):
//                        NewInvoiceView(store: invoiceStore) {
//                            store.viewState = .invoice(invoiceStore)
//                        }
//                        .padding(40)
//
//                    case .charts(let priceChart, let rateChart):
//                        ChartsView(store: store, priceChartConfig: priceChart, rateChartConfig: rateChart)
//                        .padding(40)
//
//                    case .invoice(let invoiceStore):
//                        InvoiceView(store: invoiceStore) { data in
//                            // Merge invoice data by keeping reports
//                            let reports = store.reportStore?.data.reports ?? []
//                            store.reportStore?.data = data
//                            store.reportStore?.data.reports = reports
//                            store.reportStore?.calculate()
//                        }
////                        .modifier(Toolbar(store: store))
//
//                    case .deleteInvoice(let invoice):
//                        DeleteConfirmationView(store: store, invoice: invoice)
//                        .padding(40)
//
//                    case .company(let companyDetails):
//                        NewCompanyView(store: CompaniesStore(data: companyDetails), callback: {
//                            store.viewState = .noInvoices
//                        })
//                        .padding(40)
//
//                    case .report(let reportStore):
//                        ReportView(store: reportStore).frame(width: 920)
////                        .modifier(Toolbar(store: store))
//
//                    case .error(let title, let message):
//                        VStack(alignment: .center) {
//                            Text(title).bold()
//                            Text(message)
//                        }
//                        .padding(40)
//                }
