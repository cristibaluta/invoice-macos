//
//  NewInvoiceView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewInvoiceView: View {
    
    @ObservedObject var viewModel: InvoiceEditorViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("New invoice").font(.system(size: 40)).bold()
            Text("\(viewModel.invoiceSeries)-\(viewModel.invoiceNr)")
            .font(.system(size: 20)).bold()

            Divider()//.frame(height: 200)

            VStack(alignment: .leading) {
                Spacer().frame(height: 10)

                HStack(alignment: .center) {
                    Text("Invoice date:").font(.system(size: 20))
                    DatePicker("", selection: $viewModel.invoiceDate, displayedComponents: .date)
                    .font(.system(size: 20))
                }
                
                HStack(alignment: .center) {
                    Text("Invoiced date:").font(.system(size: 20))
                    DatePicker("", selection: $viewModel.invoicedDate, displayedComponents: .date)
                    .font(.system(size: 20))
                }

                HStack(alignment: .center) {
                    Text("Exchange rate:").font(.system(size: 20))
                    Spacer()
//                    TextField("0.0", text: $viewModel.exchangeRate).font(.system(size: 20))
//                    .modifier(NumberKeyboard())
//                    .modifier(OutlineTextField())
                }
                
                HStack(alignment: .center) {
//                    Text("Quantity (\(viewModel.unitsName)):").font(.system(size: 20))
//                    Spacer()
//                    TextField("0.0", text: $viewModel.units).font(.system(size: 20))
//                    .modifier(NumberKeyboard())
//                    .modifier(OutlineTextField())
                }
            }
            Spacer()
            Spacer()
        }
    }
    
}
