//
//  InvoiceDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI
import Combine

class InvoiceEditorState: ObservableObject {

    var data: InvoiceData {
        didSet {
            invoiceDataSubject.send(data)
        }
    }

    @Published var invoiceSeries: String
    @Published var invoiceNr: String
    @Published var invoiceDate: Date
    @Published var invoicedDate: Date
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

    private var clientState: CompanyViewState
    private var contractorState: CompanyViewState

    /// Publisher for data change
    var invoiceDataPublisher: AnyPublisher<InvoiceData, Never> { invoiceDataSubject.eraseToAnyPublisher() }
    private let invoiceDataSubject = PassthroughSubject<InvoiceData, Never>()
    /// Publisher to add new company
    var addCompanyPublisher: AnyPublisher<Void, Never> { addCompanySubject.eraseToAnyPublisher() }
    let addCompanySubject = PassthroughSubject<Void, Never>()


    init (data: InvoiceData) {
        print("init InvoiceEditorState")
        self.data = data

        invoiceSeries = data.invoice_series
        invoiceNr = String(data.invoice_nr)
        invoiceDate = Date(yyyyMMdd: data.invoice_date) ?? Date()
        invoicedDate = Date(yyyyMMdd: data.invoiced_period) ?? Date()
        vat = data.vat.stringValue_2
        amountTotalVat = data.amount_total_vat.stringValue_2

        rate = data.products[0].rate.stringValue_2
        exchangeRate = data.products[0].exchange_rate.stringValue_4
        units = data.products[0].units.stringValue
        unitsName = data.products[0].units_name
        productName = data.products[0].product_name

        clientState = CompanyViewState(data: data.client)
        contractorState = CompanyViewState(data: data.contractor)
        clientName = data.client.name
        contractorName = data.contractor.name
    }
}

struct InvoiceEditor: View {

    @EnvironmentObject var companiesData: CompaniesData
    @ObservedObject private var state: InvoiceEditorState

    private var onTapAddCompany: () -> Void

    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
        return formatter
    }

    init (state: InvoiceEditorState, onTapAddCompany: @escaping () -> Void) {
        print("init InvoiceEditor")
        self.onTapAddCompany = onTapAddCompany
        self.state = state
    }
    
    var body: some View {

        let _ = Self._printChanges()

        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                Group {
                    HStack(alignment: .center) {
                        Text("Invoice series:")
                        .font(appFont)
                        TextField("", text: $state.invoiceSeries).onChange(of: state.invoiceSeries) { newValue in
                            // Data is update through onChange because didSet on the property does not work properly
                            state.data.invoice_series = newValue
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Invoice nr:")
                        .font(appFont)
                        TextField("", text: $state.invoiceNr).onChange(of: state.invoiceNr) { newValue in
                            state.data.invoice_nr = Int(newValue) ?? 0
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Invoice date:")
                        .font(appFont)
                        DatePicker("", selection: $state.invoiceDate, displayedComponents: .date)
                        .onChange(of: state.invoiceDate) { newValue in
                            state.data.invoice_date = newValue.yyyyMMdd
                        }
                        .font(appFont)
                    }
                    HStack(alignment: .center) {
                        Text("Invoiced month:")
                        .font(appFont)
                        DatePicker("", selection: $state.invoicedDate, displayedComponents: .date)
                        .onChange(of: state.invoicedDate) { newValue in
                            state.data.invoiced_period = newValue.yyyyMMdd
                        }
                        .font(appFont)
                    }
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    HStack(alignment: .center) {
                        Text("Product #1:").font(appFont)
                        TextField("", text: $state.productName).onChange(of: state.productName) { newValue in
                            state.data.products[0].product_name = newValue
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Rate #2:").font(appFont)
                        TextField("", text: $state.rate).onChange(of: state.rate) { newValue in
                            state.data.products[0].rate = Decimal(string: newValue) ?? 0
                            // When rate changes recalculate the total amount
                            state.data.calculate()
                            state.amountTotalVat = state.data.amount_total_vat.stringValue_2
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Exchange Rate #3:").font(appFont)
                        TextField("", text: $state.exchangeRate).onChange(of: state.exchangeRate) { newValue in
                            state.data.products[0].exchange_rate = Decimal(string: newValue) ?? 0
                            // When exchange rate changes recalculate the total amount
                            state.data.calculate()
                            state.amountTotalVat = state.data.amount_total_vat.stringValue_2
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Units #4:").font(appFont)
                        TextField("", text: $state.unitsName).onChange(of: state.unitsName) { newValue in
                            state.data.products[0].units_name = newValue
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Quantity #5:").font(appFont)
                        if !state.isFixedTotal {
                            TextField("", text: $state.units)
                            .onChange(of: state.units) { newValue in
                                state.data.products[0].units = Decimal(string: newValue) ?? 0
                                // When quantity changes recalculate the total amount
                                state.data.calculate()
                                state.amountTotalVat = state.data.amount_total_vat.stringValue_2
                            }
                            .font(appFont)
                            .modifier(OutlineTextField())
                            .modifier(NumberKeyboard())
                        } else {
                            Text(state.units).font(appFont)
                        }
                    }
                    HStack(alignment: .center) {
                        Text("VAT:").font(appFont)
                        TextField("VAT", text: $state.vat).onChange(of: state.vat) { newValue in
                            state.data.vat = Decimal(string: state.vat) ?? 0
                            // When VAT changes recalculate the total amount
                            state.data.calculate()
                            state.amountTotalVat = state.data.amount_total_vat.stringValue_2
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    if state.isFixedTotal {
                        HStack(alignment: .center) {
                            Text("Total amount (#7 + VAT):").font(appFont)
                            TextField("Total", text: $state.amountTotalVat).onChange(of: state.amountTotalVat) { newValue in
                                state.data.amount_total_vat = Decimal(string: newValue) ?? 0
                                // When total amount changes recalculate the quantity
                                state.data.calculate()
                                state.units = state.data.products[0].units.stringValue
                            }
                            .font(appFont)
                            .modifier(OutlineTextField())
                            .modifier(NumberKeyboard())
                        }
                    } else {
                        Text("Total amount (#7 + VAT): \(state.amountTotalVat)").font(appFont)
                    }
                    Toggle("Fixed total (recalculates the quantity)", isOn: $state.isFixedTotal).onChange(of: state.isFixedTotal) { newValue in
                        state.data.isFixedTotal = newValue
                    }
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    HStack(alignment: .center) {
                        Text("Contractor:").font(appFont)
                        Menu {
                            ForEach(companiesData.companies) { company in
                                Button(company.name, action: {
                                    state.data.contractor = company.data
                                    state.contractorName = company.data.name
                                })
                            }
                            Divider().frame(height: 1)
                            Button("Add new", action: {
                                state.addCompanySubject.send()
                                self.onTapAddCompany()
                            })
                        } label: {
                            Text(state.contractorName)
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Text("Client:").font(appFont)
                        Menu {
                            ForEach(companiesData.companies) { company in
                                Button(company.name, action: {
                                    state.data.client = company.data
                                    state.clientName = company.data.name
                                })
                            }
                            Divider().frame(height: 1)
                            Button("Add new", action: {
                                state.addCompanySubject.send()
                                self.onTapAddCompany()
                            })
                        } label: {
                            Text(state.clientName)
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .onAppear {
            companiesData.refresh()
        }
        
    }

}
