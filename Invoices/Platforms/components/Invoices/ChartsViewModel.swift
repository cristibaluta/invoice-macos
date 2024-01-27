//
//  ChartViewModel.swift
//  Invoices
//
//  Created by Cristian Baluta on 27.01.2024.
//

import Foundation
import Combine
import SwiftUI
import BarChart

class ChartsViewModel: ObservableObject {

    @Published var totalPrice = ""
    @Published var priceChartConfig = ChartConfiguration()
    @Published var rateChartConfig = ChartConfiguration()

    init (invoices: [InvoiceData]) {

        var prices = [ChartDataEntry]()
        var rates = [ChartDataEntry]()
        var total: Decimal = 0

        for invoice in invoices {
            let price = invoice.amount_total_vat.doubleValue// + Double.random(in: 0..<10000)
            let priceEntry = ChartDataEntry(x: "\(invoice.invoice_nr)", y: price)
            prices.append(priceEntry)

            let rate = invoice.products[0].rate.doubleValue// + Double.random(in: 0..<100)
            let rateEntry = ChartDataEntry(x: "\(invoice.invoice_nr)", y: rate)
            rates.append(rateEntry)

            total += invoice.amount_total_vat
        }

        // Configure charts

        priceChartConfig.data.color = .red
        priceChartConfig.xAxis.labelsColor = .gray
        priceChartConfig.xAxis.ticksColor = .gray
        priceChartConfig.labelsCTFont = CTFontCreateWithName(("SFProText-Regular" as CFString), 10, nil)
        priceChartConfig.xAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
        priceChartConfig.yAxis.labelsColor = .gray
        priceChartConfig.yAxis.ticksColor = .gray
        priceChartConfig.yAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
        priceChartConfig.yAxis.minTicksSpacing = 30.0
        priceChartConfig.yAxis.formatter = { value, decimals in
            let format = value == 0 ? "" : "RON"
            return String(format: "%.\(decimals)f \(format)", value)
        }

        rateChartConfig.data.color = .orange
        rateChartConfig.xAxis.labelsColor = .gray
        rateChartConfig.xAxis.ticksColor = .gray
        rateChartConfig.labelsCTFont = CTFontCreateWithName(("SFProText-Regular" as CFString), 10, nil)
        rateChartConfig.xAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
        rateChartConfig.yAxis.labelsColor = .gray
        rateChartConfig.yAxis.ticksColor = .gray
        rateChartConfig.yAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
        rateChartConfig.yAxis.minTicksSpacing = 30.0
        rateChartConfig.yAxis.formatter = { value, decimals in
            let format = value == 0 ? "" : "€"
            return String(format: "%.\(decimals)f \(format)", value)
        }

        // Set data

        priceChartConfig.data.entries = prices.reversed()
        rateChartConfig.data.entries = rates.reversed()
        totalPrice = total.stringValue_grouped2

        DispatchQueue.main.async {
            self.priceChartConfig.data.entries = prices.reversed()
            self.rateChartConfig.data.entries = rates.reversed()
        }
    }
}
