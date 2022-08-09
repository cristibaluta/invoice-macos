//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import Combine

class ReportEditorState: ObservableObject {

    var data: InvoiceData

    @Published var invoiceSeries: String
    @Published var invoiceNr: String
    @Published var date: Date
    @Published var rate: String
    @Published var exchangeRate: String
    @Published var units: String
    @Published var unitsName: String
    @Published var productName: String
    @Published var vat: String
    @Published var amountTotalVat: String
    @Published var isFixedTotal: Bool = false
    @Published var clientName: String = "Add new"
    @Published var contractorName: String = "Add new"


    init (data: InvoiceData) {
        print("init InvoiceEditorState")
        self.data = data

        invoiceSeries = data.invoice_series
        invoiceNr = String(data.invoice_nr)
        date = Date(yyyyMMdd: data.invoice_date) ?? Date()
        vat = data.vat.stringValue_2
        amountTotalVat = data.amount_total_vat.stringValue_2

        rate = data.products[0].rate.stringValue_2
        exchangeRate = data.products[0].exchange_rate.stringValue_4
        units = data.products[0].units.stringValue
        unitsName = data.products[0].units_name
        productName = data.products[0].product_name

//        clientState = CompanyViewState(data: data.client)
//        contractorState = CompanyViewState(data: data.contractor)
        clientName = data.client.name
        contractorName = data.contractor.name
    }
}

struct ReportEditor: View {
    
    @ObservedObject var state: ReportState
    private var onChange: (InvoiceData) -> Void
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]
    
    init (state: ReportState, onChange: @escaping (InvoiceData) -> Void) {
        self.state = state
        self.onChange = onChange
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<state.allProjects.count) { i in
                        Toggle(state.allProjects[i].name, isOn: $state.allProjects[i].isOn)
                        .onChange(of: state.allProjects[i].isOn) { val in
                            state.updateReports()
                            onChange(state.data)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 50)
            .padding(10)

            Divider()
            List(self.state.reports) { report in
                ReportRowView(report: report) { newReport in
                    state.updateReport(newReport)
                    onChange(state.data)
                }
            }
        }

    }

}
