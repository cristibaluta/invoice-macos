//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI
import Combine

struct SidebarColumn: View {

    @EnvironmentObject var projectsState: ProjectsState
    @EnvironmentObject var invoicesState: InvoicesState
    @EnvironmentObject var companiesState: CompaniesState
    @EnvironmentObject var contentColumnState: ContentColumnState

    @State private var isShowingAddPopover = false
    @State private var isShowingCompanyDetailsPopover = false
    @State private var isShowingAddCompanyPopover = false
    @State private var selectedInvoice: InvoiceFolder? {
        didSet {
            let _ = invoicesState.loadInvoice(selectedInvoice!).sink { state in
                contentColumnState.invoiceReportState = state
                contentColumnState.type = .invoice(state)
                state.calculate()
            }
        }
    }


    var body: some View {

        let _ = Self._printChanges()
        
        VStack(alignment: .leading) {
            Text("Projects").bold().padding(.leading, 16)
            Menu {
                ForEach(projectsState.projects) { project in
                    Button(project.name, action: {
                        projectsState.selectedProject = project
                        invoicesState.refresh(project)
                    })
                }
            } label: {
                Text(projectsState.selectedProject?.name ?? "Select project")
            }
            .padding(16)

            Divider().padding(16)

            Text("Invoices").bold().padding(.leading, 16)
            List(invoicesState.invoices, id: \.self, selection: $selectedInvoice) { invoice in
                HStack {
                    Text(invoice.name)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedInvoice = invoice
                }
                .contextMenu {
                    Button(action: {
                        invoicesState.showInFinder(invoice)
                    }) {
                        Text("Show in Finder")
                    }
                    Button(action: {
                        contentColumnState.type = .deleteInvoice(invoice)
                    }) {
                        Text("Delete")
                    }
                }
            }
            .listStyle(SidebarListStyle())

            Divider().padding(16)

            Text("Companies").bold().padding(.leading, 16)
            List(companiesState.companies, id: \.self, selection: $invoicesState.selectedInvoice) { comp in
                Button(comp.name, action: {
                    companiesState.selectedCompany = comp.data
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
                CompanyPopover(data: companiesState.selectedCompany!)
                .frame(width: 400)
            }

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
                        contentColumnState.type = .noProjects
                    }
                    Button("New Invoice") {
                        isShowingAddPopover = false
                        invoicesState.createNextInvoiceInProject()
                    }
                    Button("New company") {
                        isShowingAddPopover = false
                        contentColumnState.type = .company(CompaniesInteractor.emptyCompanyDetails)
                    }
                }
                .padding(20)
            }
        }
        .onAppear {
            contentColumnState.chartCancellable = invoicesState.chartPublisher.sink { values in
                if invoicesState.invoices.isEmpty {
                    contentColumnState.type = .noInvoices
                } else {
                    contentColumnState.type = .charts(values.0, values.1, values.2)
                }
            }
            contentColumnState.newInvoiceCancellable = invoicesState.newInvoicePublisher.sink { invoiceReportState in
                contentColumnState.invoiceReportState = invoiceReportState
                contentColumnState.type = .invoice(invoiceReportState)
            }
        }

    }

}
