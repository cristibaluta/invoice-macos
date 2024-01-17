//
//  InvoiceDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI
import Combine

class InvoiceEditorViewModel: ObservableObject, InvoiceEditorProtocol {

    let type: EditorType = .invoice
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

    private var clientViewModel: CompanyViewViewModel
    private var contractorViewModel: CompanyViewViewModel

    /// Publisher for data change
    var invoiceDataChangePublisher: AnyPublisher<InvoiceData, Never> { invoiceDataSubject.eraseToAnyPublisher() }
    private let invoiceDataSubject = PassthroughSubject<InvoiceData, Never>()
    /// Publisher to add new company
    var addCompanyPublisher: AnyPublisher<Void, Never> { addCompanySubject.eraseToAnyPublisher() }
    let addCompanySubject = PassthroughSubject<Void, Never>()


    init (data: InvoiceData) {
        print(">>>>>>>> init InvoiceEditorViewModel")
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

        clientViewModel = CompanyViewViewModel(data: data.client)
        contractorViewModel = CompanyViewViewModel(data: data.contractor)
        clientName = data.client.name
        contractorName = data.contractor.name
    }

    deinit {
        print("<<<<<<< deinit InvoiceEditorViewModel")
    }
}

struct InvoiceEditor: View {

    @EnvironmentObject var companiesData: CompaniesStore
    @ObservedObject private var viewModel: InvoiceEditorViewModel

    private var onTapAddCompany: () -> Void

    init (viewModel: InvoiceEditorViewModel, onTapAddCompany: @escaping () -> Void) {
        print("init InvoiceEditor")
        self.onTapAddCompany = onTapAddCompany
        self.viewModel = viewModel
    }
    
    var body: some View {

        let _ = Self._printChanges()

        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                Group {
                    HStack(alignment: .center) {
                        Text("Invoice series:")
                        .font(appFont)
                        TextField("", text: $viewModel.invoiceSeries)
                        .onChange(of: viewModel.invoiceSeries) { newValue in
                            // Data is update through onChange because didSet on the property does not work properly
                            viewModel.data.invoice_series = newValue
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Invoice nr:")
                        .font(appFont)
                        TextField("", text: $viewModel.invoiceNr)
                        .onChange(of: viewModel.invoiceNr) { newValue in
                            viewModel.data.invoice_nr = Int(newValue) ?? 0
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Invoice date:")
                        .font(appFont)
                        DatePicker("", selection: $viewModel.invoiceDate, displayedComponents: .date)
                        .onChange(of: viewModel.invoiceDate) { newValue in
                            viewModel.data.invoice_date = newValue.yyyyMMdd
                        }
                        .font(appFont)
                    }
                    HStack(alignment: .center) {
                        Text("Invoiced month:")
                        .font(appFont)
                        DatePicker("", selection: $viewModel.invoicedDate, displayedComponents: .date)
                        .onChange(of: viewModel.invoicedDate) { newValue in
                            viewModel.data.invoiced_period = newValue.yyyyMMdd
                        }
                        .font(appFont)
                    }
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    HStack(alignment: .center) {
                        Text("Product #1:").font(appFont)
                        TextField("", text: $viewModel.productName)
                        .onChange(of: viewModel.productName) { newValue in
                            viewModel.data.products[0].product_name = newValue
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Rate #2:").font(appFont)
                        TextField("", text: $viewModel.rate)
                        .onChange(of: viewModel.rate) { newValue in
                            viewModel.data.products[0].rate = Decimal(string: newValue) ?? 0
                            // When rate changes recalculate the total amount
                            viewModel.data.calculate()
                            viewModel.amountTotalVat = viewModel.data.amount_total_vat.stringValue_2
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Exchange Rate #3:").font(appFont)
                        TextField("", text: $viewModel.exchangeRate)
                        .onChange(of: viewModel.exchangeRate) { newValue in
                            viewModel.data.products[0].exchange_rate = Decimal(string: newValue) ?? 0
                            // When exchange rate changes recalculate the total amount
                            viewModel.data.calculate()
                            viewModel.amountTotalVat = viewModel.data.amount_total_vat.stringValue_2
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Units #4:").font(appFont)
                        TextField("", text: $viewModel.unitsName)
                        .onChange(of: viewModel.unitsName) { newValue in
                            viewModel.data.products[0].units_name = newValue
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Quantity #5:").font(appFont)
                        if !viewModel.isFixedTotal {
                            TextField("", text: $viewModel.units)
                            .onChange(of: viewModel.units) { newValue in
                                viewModel.data.products[0].units = Decimal(string: newValue) ?? 0
                                // When quantity changes recalculate the total amount
                                viewModel.data.calculate()
                                viewModel.amountTotalVat = viewModel.data.amount_total_vat.stringValue_2
                            }
                            .font(appFont)
                            .modifier(OutlineTextField())
                            .modifier(NumberKeyboard())
                        } else {
                            Text(viewModel.units).font(appFont)
                        }
                    }
                    HStack(alignment: .center) {
                        Text("VAT:").font(appFont)
                        TextField("VAT", text: $viewModel.vat)
                        .onChange(of: viewModel.vat) { newValue in
                            viewModel.data.vat = Decimal(string: viewModel.vat) ?? 0
                            // When VAT changes recalculate the total amount
                            viewModel.data.calculate()
                            viewModel.amountTotalVat = viewModel.data.amount_total_vat.stringValue_2
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    if viewModel.isFixedTotal {
                        HStack(alignment: .center) {
                            Text("Total amount (#7 + VAT):").font(appFont)
                            TextField("Total", text: $viewModel.amountTotalVat)
                            .onChange(of: viewModel.amountTotalVat) { newValue in
                                viewModel.data.amount_total_vat = Decimal(string: newValue) ?? 0
                                // When total amount changes recalculate the quantity
                                viewModel.data.calculate()
                                viewModel.units = viewModel.data.products[0].units.stringValue
                            }
                            .font(appFont)
                            .modifier(OutlineTextField())
                            .modifier(NumberKeyboard())
                        }
                    } else {
                        Text("Total amount (#7 + VAT): \(viewModel.amountTotalVat)").font(appFont)
                    }
                    Toggle("Fixed total (recalculates the quantity)", isOn: $viewModel.isFixedTotal)
                    .onChange(of: viewModel.isFixedTotal) { newValue in
                        viewModel.data.isFixedTotal = newValue
                    }
                }
                
                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    HStack(alignment: .center) {
                        Text("Contractor:").font(appFont)
                        Menu {
                            ForEach(companiesData.companies) { company in
                                Button(company.name, action: {
                                    viewModel.data.contractor = company.data
                                    viewModel.contractorName = company.data.name
                                })
                            }
                            Divider().frame(height: 1)
                            Button("Add new", action: {
                                viewModel.addCompanySubject.send()
                                self.onTapAddCompany()
                            })
                        } label: {
                            Text(viewModel.contractorName)
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Text("Client:").font(appFont)
                        Menu {
                            ForEach(companiesData.companies) { company in
                                Button(company.name, action: {
                                    viewModel.data.client = company.data
                                    viewModel.clientName = company.data.name
                                })
                            }
                            Divider().frame(height: 1)
                            Button("Add new", action: {
                                viewModel.addCompanySubject.send()
                                self.onTapAddCompany()
                            })
                        } label: {
                            Text(viewModel.clientName)
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
