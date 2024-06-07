//
//  ProductRowView.swift
//  Invoices
//
//  Created by Cristian Baluta on 22.02.2024.
//

import Foundation
import SwiftUI

struct ProductRowView: View {

    @ObservedObject var viewModel: ProductRowModel

    var body: some View {

        let _ = Self._printChanges()

        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Product:").font(appFont)
                TextField("", text: $viewModel.productName)
                    .font(appFont)
                    .modifier(OutlineTextField())
            }
            .padding()

            Divider().padding(0)

            HStack(alignment: .bottom) {
                VStack(alignment: .center) {
                    Text("Rate #1:").font(smallFont)
                    TextField("", text: $viewModel.rate)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                }
                Divider()
                VStack(alignment: .center) {
                    Text("Exchange Rate #2:").font(smallFont)
                    HStack {
                        TextField("", text: $viewModel.exchangeRate)
                            .font(appFont)
                            .modifier(OutlineTextField())
                            .modifier(NumberKeyboard())
                        Button {
                            viewModel.requestExchangeRate()
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                Divider()
                VStack(alignment: .center) {
                    Text("Units #3:").font(smallFont)
                    TextField("", text: $viewModel.unitsName)
                        .font(appFont)
                        .modifier(OutlineTextField())
                }
                Divider()
                VStack(alignment: .center) {
                    Text("Quantity #4:").font(smallFont)
                    TextField("", text: $viewModel.units)
                        .font(appFont)
                        .modifier(OutlineTextField())
                        .modifier(NumberKeyboard())
                }
            }
            .padding()

            HStack(alignment: .center) {
                Text("Total (1x2x4): \(viewModel.amount)").font(appFont)
            }
            .padding()
        }
        #if os(iOS)
        .background(Color(.systemGray6))
        #endif
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
    }
}
