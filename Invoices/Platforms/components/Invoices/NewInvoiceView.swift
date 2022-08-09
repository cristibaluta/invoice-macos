//
//  NewInvoiceView.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.12.2021.
//

import SwiftUI

struct NewInvoiceView: View {
    
    @ObservedObject var state: InvoiceEditorState
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("New invoice").font(.system(size: 40)).bold()
            Text("\(state.invoiceSeries)-\(state.invoiceNr)")
                .font(.system(size: 20)).bold()

            Divider()//.frame(height: 200)

            VStack(alignment: .leading) {
                Spacer().frame(height: 10)

                HStack(alignment: .center) {
                    Text("Invoice date:").font(.system(size: 20))
                    DatePicker("", selection: $state.date, displayedComponents: .date)
                    .font(.system(size: 20))
                }
                
                HStack(alignment: .center) {
                    Text("Exchange rate:").font(.system(size: 20))
                    Spacer()
                    TextField("0.0", text: $state.exchangeRate).font(.system(size: 20))//.frame(width: 100)
                    .modifier(NumberKeyboard())
                    .modifier(OutlineTextField())
                }
                
                HStack(alignment: .center) {
                    Text("Quantity (\(state.unitsName)):").font(.system(size: 20))
                    Spacer()
                    TextField("0.0", text: $state.units).font(.system(size: 20))//.frame(width: 100)
                    .modifier(NumberKeyboard())
                    .modifier(OutlineTextField())
                }
            }
            Spacer()
            Spacer()
        }
    }
    
}
