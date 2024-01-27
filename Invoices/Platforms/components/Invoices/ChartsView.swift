//
//  ChartsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.11.2021.
//

import SwiftUI
import BarChart

struct ChartsView: View {
    
    @ObservedObject var viewModel: ChartsViewModel
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Invoiced amount").bold()
            Text("All time total: \(viewModel.totalPrice) RON")
            BarChartView(config: viewModel.priceChartConfig)
            .frame(height: 300)
//            .animation(.easeInOut)
            
            Spacer().frame(height: 30)
            
            Text("Hourly rate").bold()
            BarChartView(config: viewModel.rateChartConfig)
            .frame(height: 150)
//            .animation(.easeInOut)
        }
    }

}
