//
//  ChartsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.11.2021.
//

import SwiftUI
import BarChart

class ChartsViewState: ObservableObject {
    @Published var totalPrice: String
    init (total: Decimal) {
        totalPrice = total.stringValue_grouped2
    }
}

struct ChartsView: View {
    
    @ObservedObject var state: ChartsViewState
    var priceChartConfig: ChartConfiguration
    var rateChartConfig: ChartConfiguration
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Invoiced amount").bold()
            Text("All time total: \(state.totalPrice) RON")
            BarChartView(config: priceChartConfig)
            .frame(height: 300)
//            .animation(.easeInOut)
            
            Spacer().frame(height: 30)
            
            Text("Hourly rate").bold()
            BarChartView(config: rateChartConfig)
            .frame(height: 150)
//            .animation(.easeInOut)
        }
    }

}
