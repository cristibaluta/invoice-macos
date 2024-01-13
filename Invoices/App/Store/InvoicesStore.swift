//
//  InvoicesState.swift
//  Invoices
//
//  Created by Cristian Baluta on 19.07.2022.
//

import Foundation
import Combine
import BarChart
import SwiftUI

class InvoicesStore: ObservableObject {

    @Published var invoices: [Invoice] = []
//    @Published var selectedInvoice: Invoice?
    @Published var isShowingNewInvoiceSheet = false
    @Published var isShowingEditInvoiceSheet = false
    @Published var isShowingDeleteInvoiceAlert = false

//    private var cancellable: Cancellable?
    private let invoicesInteractor: InvoicesInteractor
    private let reportsInteractor: ReportsInteractor

    var project: Project
    var selectedInvoiceStore: InvoiceStore?
    var selectedReportStore: ReportStore?

    var priceChartConfig = ChartConfiguration()
    var rateChartConfig = ChartConfiguration()
    var priceChartEntries: [ChartDataEntry] = []
    var rateChartEntries: [ChartDataEntry] = []


    var chartPublisher: AnyPublisher<(ChartConfiguration, ChartConfiguration, Decimal), Never> {
        subject.eraseToAnyPublisher()
    }
    private let subject = PassthroughSubject<(ChartConfiguration, ChartConfiguration, Decimal), Never>()

    var newInvoicePublisher: AnyPublisher<(InvoiceStore), Never> {
        newInvoiceSubject.eraseToAnyPublisher()
    }
    private let newInvoiceSubject = PassthroughSubject<(InvoiceStore), Never>()


    init (repository: Repository, project: Project) {
        
        self.project = project

        invoicesInteractor = InvoicesInteractor(repository: repository)
        reportsInteractor = ReportsInteractor(repository: repository)
        self.selectedInvoiceStore = InvoiceStore(project: Project(name: ""),
                                                       data: InvoicesInteractor.emptyInvoiceData,
                                                       invoicesInteractor: invoicesInteractor)
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
    }

    func loadInvoices() {
        _ = invoicesInteractor.refreshInvoicesList(for: project)
            .print("InvoicesState")
            .sink { [weak self] in
                self?.invoices = $0
                self?.loadChart()
            }
    }

    func loadInvoice (_ invoice: Invoice) -> AnyPublisher<InvoiceStore, Never> {

        return invoicesInteractor.readInvoice(for: invoice, in: project)
            .map { invoiceData in
                // TODO map should not save to instance vars
                let invoiceStore = InvoiceStore(project: self.project,
                                                data: invoiceData,
                                                invoicesInteractor: self.invoicesInteractor)
                self.selectedInvoiceStore = invoiceStore
                return invoiceStore
            }
            .eraseToAnyPublisher()
    }

    func createNextInvoiceInProject() {

        guard let lastInvoice = invoices.first else {
            // If this is the first invoice create an empty invoice
            let data = InvoicesInteractor.emptyInvoiceData
            let invoice = Invoice(date: data.date,
                                  invoiceNr: "\(data.invoice_series)\(data.invoice_nr)",
                                  name: "\(data.date.yyyyMMdd)-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)")
            self.invoices = [invoice]
            self.selectedInvoiceStore = InvoiceStore(project: project,
                                                          data: data,
                                                          invoicesInteractor: self.invoicesInteractor)
            self.selectedInvoiceStore?.calculate()
//            self.newInvoiceSubject.send(self.selectedInvoiceStore)
            return
        }

        _ = invoicesInteractor.readInvoice(for: lastInvoice, in: project)
        .sink {
            var data = $0
            /// Increase invoice nr
            data.invoice_nr += 1
            /// Set invoice date to last working day of the next month
            let nextDate = Date(yyyyMMdd: data.invoice_date)?.nextMonth().endOfMonth(lastWorkingDay: true) ?? Date()
            data.invoice_date = nextDate.yyyyMMdd
            /// Remove the old reports
            data.reports = []
            /// Create new invoice and insert it in the list
            let invoice = Invoice(date: nextDate,
                                  invoiceNr: "\(data.invoice_series)\(data.invoice_nr)",
                                  name: "\(nextDate.yyyyMMdd)-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)")
            self.invoices.insert(invoice, at: 0)
            /// Update the state
            self.selectedInvoiceStore = InvoiceStore(project: self.project,
                                                          data: data,
                                                          invoicesInteractor: self.invoicesInteractor)
            self.selectedInvoiceStore?.calculate()
//            self.newInvoiceSubject.send(self.selectedInvoiceStore)
        }
    }

    func deleteInvoice (at index: Int) {
        guard index < invoices.count else {
            return
        }
        let invoice = invoices[index]
        _ = invoicesInteractor.deleteInvoice(invoice, in: project)
            .sink { success in
                self.invoices.remove(at: index)
            }
    }

    func deleteInvoice (_ invoice: Invoice) {
        guard let index = invoices.firstIndex(of: invoice) else {
            fatalError("Index not found")
        }
        _ = invoicesInteractor.deleteInvoice(invoice, in: project)
            .sink { success in
                self.invoices.remove(at: index)
                self.loadChart()
            }
    }

    func dismissNewInvoice() {
        self.isShowingNewInvoiceSheet = false
    }

    func dismissInvoiceEditor() {
        self.isShowingEditInvoiceSheet = false
    }

    func dismissDeleteInvoice() {
        self.isShowingDeleteInvoiceAlert = false
    }

    func path (for invoice: Invoice) -> String {
//        let invoiceUrl = baseUrl.appendingPathComponent(project.name).appendingPathComponent(invoice.name)
//        return invoiceUrl.path
        return ""
    }


    func loadChart() {
        guard !invoices.isEmpty else {
            priceChartConfig.data.entries = []
            rateChartConfig.data.entries = []
            subject.send((priceChartConfig, rateChartConfig, 0))
            return
        }

        let folderPath = project.name
        var prices = [ChartDataEntry]()
        var rates = [ChartDataEntry]()
        var total: Decimal = 0
//        for invoice in invoices {
//            // Load all invoices data and display a chart
//            let invoiceDataPath = "\(folderPath)/\(invoice.name)/data.json"
//            if FileManager.default.fileExists(atPath: invoiceDataPath) {
//                print("File exists \(invoiceDataPath)")
//            } else {
//                print("Start downloading \(invoiceDataPath)")
//                do {
//                    try FileManager.default.startDownloadingUbiquitousItem(at: invoiceDataPath)
//                } catch {
//                    print("Error while loading Backup File \(error)")
//                }
//            }
//            do {
//                let jsonData = try Data(contentsOf: invoiceDataPath)
//                let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
//                let price = invoice.amount_total_vat.doubleValue// + Double.random(in: 0..<10000)
//                total += invoice.amount_total_vat
//                let priceEntry = ChartDataEntry(x: "\(invoice.invoice_nr)", y: price)
//                prices.append(priceEntry)
//                let rate = invoice.products[0].rate.doubleValue// + Double.random(in: 0..<100)
//                let rateEntry = ChartDataEntry(x: "\(invoice.invoice_nr)", y: rate)
//                rates.append(rateEntry)
//            } catch {
//                print("\(error)")
//            }
//        }
        showChart(prices, rates, total)
    }
    
    func showChart (_ prices: [ChartDataEntry]?, _ rates: [ChartDataEntry]?, _ total: Decimal) {
        
        if let prices = prices, let rates = rates {
            self.priceChartEntries = prices.reversed()
            self.rateChartEntries = rates.reversed()
        }
        DispatchQueue.main.async {
            self.priceChartConfig.data.entries = self.priceChartEntries
            self.rateChartConfig.data.entries = self.rateChartEntries
            self.subject.send((self.priceChartConfig, self.rateChartConfig, total))
            // Bug in charts, need to set the data twice
            DispatchQueue.main.async {
                self.priceChartConfig.data.entries = self.priceChartEntries
                self.rateChartConfig.data.entries = self.rateChartEntries
                self.subject.send((self.priceChartConfig, self.rateChartConfig, total))
            }
        }
    }
}

