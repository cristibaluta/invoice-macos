//
//  InvoiceDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.11.2021.
//

import SwiftUI
import Combine

struct InvoiceEditorView: View {

    @EnvironmentObject var companiesData: CompaniesStore
    @ObservedObject private var model: InvoiceEditorModel

    private var onTapAddCompany: () -> Void

    init (model: InvoiceEditorModel, onTapAddCompany: @escaping () -> Void) {
        self.onTapAddCompany = onTapAddCompany
        self.model = model
    }
    
    var body: some View {

        let _ = Self._printChanges()

        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                Group {
                    HStack(alignment: .center) {
                        Text("Invoice series:")
                        .font(appFont)
                        TextField("", text: $model.invoiceSeries)
                        .font(appFont)
                        .modifier(OutlineTextField())
                    }
                    HStack(alignment: .center) {
                        Text("Invoice nr:")
                        .font(appFont)
                        TextField("", text: $model.invoiceNr)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Invoice date:")
                        .font(appFont)
                        DatePicker("", selection: $model.invoiceDate, displayedComponents: .date)
                        .font(appFont)
                    }
                    HStack(alignment: .center) {
                        Text("Invoiced month:")
                        .font(appFont)
                        DatePicker("", selection: $model.invoicedDate, displayedComponents: .date)
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
                                    model.data.contractor = company.data
                                    model.contractorName = company.data.name
                                })
                            }
                            Divider().frame(height: 1)
                            Button("Add new", action: {
                                model.addCompanySubject.send()
                                onTapAddCompany()
                            })
                        } label: {
                            Text(model.contractorName)
                        }
                    }

                    HStack(alignment: .center) {
                        Text("Client:").font(appFont)
                        Menu {
                            ForEach(companiesData.companies) { company in
                                Button(company.name, action: {
                                    model.data.client = company.data
                                    model.clientName = company.data.name
                                })
                            }
                            Divider().frame(height: 1)
                            Button("Add new", action: {
                                model.addCompanySubject.send()
                                onTapAddCompany()
                            })
                        } label: {
                            Text(model.clientName)
                        }
                    }
                    Spacer()
                }

                Divider().padding(.top, 10).padding(.bottom, 10)

                ForEach(Array(model.products.enumerated()), id: \.offset) { index, product in
                    ProductRowView(viewModel: product)
                }
                Button("+ Add new product", action: {
                    model.addNewProduct()
                })
                .padding(.top, 16)

                Divider().padding(.top, 10).padding(.bottom, 10)
                
                Group {
                    HStack(alignment: .center) {
                        Text("VAT %:").font(appFont)
                        TextField("VAT", text: $model.vatPercent)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("VAT amount (#7 * VAT %):").font(appFont)
                        TextField("VAT amount", text: $model.vatAmount)
                        .disabled(true)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                    HStack(alignment: .center) {
                        Text("Total amount (#7 + VAT):").font(appFont)
                        TextField("Total", text: $model.amountTotalVat)
                        .disabled(true)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                    }
                }

            }
            .padding()
        }
        .onAppear {
            companiesData.refresh()
        }
        
    }

}
