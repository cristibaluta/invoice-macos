//
//  SidebarView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI
import Combine

struct SidebarColumn: View {

    @EnvironmentObject var projectsData: ProjectsData
    @EnvironmentObject var invoicesData: InvoicesData
    @EnvironmentObject var companiesData: CompaniesData
    @EnvironmentObject var contentColumnState: ContentColumnState

    @State private var isShowingAddPopover = false
    @State private var isShowingCompanyDetailsPopover = false
    @State private var isShowingAddCompanyPopover = false
    @State private var selectedInvoice: Invoice? {
        didSet {
            _ = invoicesData.loadInvoice(selectedInvoice!)
                .sink { state in
                    contentColumnState.contentData = state
                    contentColumnState.type = .invoice(state)
                    state.calculate()
                }
        }
    }


    var body: some View {

        let _ = Self._printChanges()
        
        VStack(alignment: .leading) {

            // Folders section

            Text("Projects").bold().padding(.leading, 16)
            Menu {
                ForEach(projectsData.projects) { project in
                    Button(project.name, action: {
                        projectsData.selectedProject = project
                        invoicesData.refresh(project)
                    })
                }
            } label: {
                Text(projectsData.selectedProject?.name ?? "Select project")
            }
            .padding(16)

            // Invoices section

            Divider().padding(16)

            Text("Invoices").bold().padding(.leading, 16)
            List(invoicesData.invoices, id: \.self, selection: $selectedInvoice) { invoice in
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
                        invoicesData.showInFinder(invoice)
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

            // Companies section

            Divider().padding(16)

            Text("Companies").bold().padding(.leading, 16)
            List(companiesData.companies, id: \.self, selection: $invoicesData.selectedInvoice) { comp in
                Button(comp.name, action: {
                    companiesData.selectedCompany = comp.data
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
                CompanyPopover(data: companiesData.selectedCompany!)
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
                        contentColumnState.type = .noProjects
                    }
                    Button("New Invoice") {
                        isShowingAddPopover = false
                        invoicesData.createNextInvoiceInProject()
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
            contentColumnState.chartCancellable = invoicesData.chartPublisher.sink { values in
                if invoicesData.invoices.isEmpty {
                    contentColumnState.type = .noInvoices
                } else {
                    contentColumnState.type = .charts(values.0, values.1, values.2)
                }
            }
            contentColumnState.newInvoiceCancellable = invoicesData.newInvoicePublisher.sink { contentData in
                contentColumnState.contentData = contentData
                contentColumnState.type = .invoice(contentData)
            }
        }

    }

}
