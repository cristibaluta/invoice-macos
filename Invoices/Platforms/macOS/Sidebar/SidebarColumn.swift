//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI
import Combine

struct SidebarColumn: View {

    @EnvironmentObject var store: Store
    @EnvironmentObject var companiesStore: CompaniesStore
    @EnvironmentObject var mainViewState: MainViewState

    @State private var isShowingAddPopover = false
    @State private var isShowingCompanyDetailsPopover = false
    @State private var isShowingAddCompanyPopover = false


    var body: some View {

        let _ = Self._printChanges()
        
        VStack(alignment: .leading) {

            // Projects section
            ProjectsMenu(projectsStore: store.projectsStore)

            // Invoices section
            Divider().padding(16)
            if let invoicesStore = store.projectsStore.invoicesStore {
                InvoicesList(invoicesStore: invoicesStore)
            }

            // Companies section

            Divider().padding(16)

            Text("Companies").bold().padding(.leading, 16)
            List(companiesStore.companies, id: \.self) { comp in
                Button(comp.name, action: {
                    companiesStore.selectedCompany = comp.data
                    isShowingCompanyDetailsPopover = true
                })
                .contextMenu {
                    Button(action: {
//                        contentColumnState.type = .deleteInvoice(invoice)
                    }) {
                        Text("Delete")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .popover(isPresented: $isShowingCompanyDetailsPopover) {
                CompanyPopover(data: companiesStore.selectedCompany!)
                .frame(width: 400)
            }

            // Add new section

            Divider()

            Button(action: { isShowingAddPopover = true }) {
                HStack {
                    Image(systemName: "plus.app")
                    Text("Add new")
                }
            }
            .padding(16)
            .background(Color.clear)
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $isShowingAddPopover) {
                VStack {
                    Button("New Project") {
                        isShowingAddPopover = false
                        mainViewState.type = .noProjects
                    }
                    Button("New Invoice") {
                        isShowingAddPopover = false
                        store.projectsStore.invoicesStore?.createNextInvoiceInProject()
                    }
                    Button("New company") {
                        isShowingAddPopover = false
                        mainViewState.type = .company(CompaniesInteractor.emptyCompanyDetails)
                    }
                }
                .padding(20)
            }
        }
        .onAppear {
            mainViewState.chartCancellable = store.projectsStore.invoicesStore!.chartPublisher.sink { values in
                if store.projectsStore.invoicesStore?.invoices.isEmpty ?? false {
                    mainViewState.type = .noInvoices
                } else {
                    mainViewState.type = .charts(values.0, values.1, values.2)
                }
            }
            mainViewState.newInvoiceCancellable = store.projectsStore.invoicesStore!.newInvoicePublisher.sink { contentData in
//                mainViewState.contentData = contentData
//                mainViewState.type = .invoice(contentData)
            }
        }

    }

}
