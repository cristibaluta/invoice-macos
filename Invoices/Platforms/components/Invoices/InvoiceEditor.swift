//
//  InvoiceDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI
import Combine

struct InvoiceEditor: View {

    @EnvironmentObject var companiesData: CompaniesStore
    @ObservedObject private var viewModel: InvoiceEditorViewModel

    private var onTapAddCompany: () -> Void

    init (viewModel: InvoiceEditorViewModel, onTapAddCompany: @escaping () -> Void) {
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
                
                Divider().padding(.top, 10).padding(.bottom, 10)

                ForEach(Array(viewModel.products.enumerated()), id: \.offset) { index, product in
                    InvoiceProductEditor(viewModel: product) { updatedProduct in
                        viewModel.data.products[index] = updatedProduct.data
                        viewModel.data.calculate()
                        viewModel.amountTotalVat = viewModel.data.amount_total_vat.stringValue_2
                    }
                }
                Button("+ Add new product", action: {
                    viewModel.addNewProduct()
                })

                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
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
                    HStack(alignment: .center) {
                        Text("Total amount (#7 + VAT):").font(appFont)
                        TextField("Total", text: $viewModel.amountTotalVat)
                        .disabled(true)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
//                    if viewModel.isFixedTotal {
//                        HStack(alignment: .center) {
//                            Text("Total amount (#7 + VAT):").font(appFont)
//                            TextField("Total", text: $viewModel.amountTotalVat)
//                            .onChange(of: viewModel.amountTotalVat) { newValue in
//                                viewModel.data.amount_total_vat = Decimal(string: newValue) ?? 0
//                                // When total amount changes recalculate the quantity
//                                viewModel.data.calculate()
//                                viewModel.units = viewModel.data.products[0].units.stringValue
//                            }
//                            .font(appFont)
//                            .modifier(OutlineTextField())
//                            .modifier(NumberKeyboard())
//                        }
//                    } else {
//                        Text("Total amount (#7 + VAT): \(viewModel.amountTotalVat)").font(appFont)
//                    }
//                    Toggle("Fixed total (recalculates the quantity)", isOn: $viewModel.isFixedTotal)
//                    .onChange(of: viewModel.isFixedTotal) { newValue in
//                        viewModel.data.isFixedTotal = newValue
//                    }
                }

            }
            .padding()
        }
        .onAppear {
            companiesData.refresh()
        }
        
    }

}

struct InvoiceProductEditor: View {

    @ObservedObject var viewModel: InvoiceProductEditorViewModel
    var onChange: (InvoiceProductEditorViewModel) -> Void

    var body: some View {

        let _ = Self._printChanges()

        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Product:").font(appFont)
                TextField("", text: $viewModel.productName)
                    .onChange(of: viewModel.productName) { newValue in
                        viewModel.data.product_name = newValue
                        calculateAmount()
                    }
                    .font(appFont)
                    .modifier(OutlineTextField())
            }
            .padding()

            Divider().padding(0)

            HStack {
                VStack(alignment: .center) {
                    Text("Rate #1:").font(appFont)
                    TextField("", text: $viewModel.rate)
                        .onChange(of: viewModel.rate) { newValue in
                            viewModel.data.rate = Decimal(string: newValue) ?? 0
                            // When rate changes recalculate the total amount
                            calculateAmount()
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                }
                Divider()
                VStack(alignment: .center) {
                    Text("Exchange Rate #2:").font(appFont)
                    TextField("", text: $viewModel.exchangeRate)
                        .onChange(of: viewModel.exchangeRate) { newValue in
                            viewModel.data.exchange_rate = Decimal(string: newValue) ?? 0
                            // When exchange rate changes recalculate the total amount
                            calculateAmount()
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                }
                Divider()
                VStack(alignment: .center) {
                    Text("Units #3:").font(appFont)
                    TextField("", text: $viewModel.unitsName)
                        .onChange(of: viewModel.unitsName) { newValue in
                            viewModel.data.units_name = newValue
                            calculateAmount()
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                }
                Divider()
                VStack(alignment: .center) {
                    Text("Quantity #4:").font(appFont)
                    TextField("", text: $viewModel.units)
                        .onChange(of: viewModel.units) { newValue in
                            viewModel.data.units = Decimal(string: newValue) ?? 0
                            // When quantity changes recalculate the total amount
                            calculateAmount()
                        }
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                }
            }
            .padding()

            HStack(alignment: .center) {
                Text("Total (#1 * #2 * #4): \(viewModel.amount)").font(appFont)
            }
            .padding()
        }
        .background(.clear)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
    }

    private func calculateAmount() {
        onChange(viewModel)
    }
}
