//
//  ChartsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.11.2021.
//

import SwiftUI
import BarChart

struct ChartsView: View {
    
    @ObservedObject var store: ContentStore
    var priceChartConfig: ChartConfiguration
    var rateChartConfig: ChartConfiguration
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Invoiced amount").bold()
            Text("All time total: \(store.totalPrice) RON")
            BarChartView(config: priceChartConfig)
            .frame(height: 300)
            .padding(20)
            .animation(.easeInOut)
            
            Spacer().frame(height: 30)
            
            Text("Hourly rate").bold()
            BarChartView(config: rateChartConfig)
            .frame(height: 150)
            .padding(20)
            .animation(.easeInOut)
        }
    }
}
