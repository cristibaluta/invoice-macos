//
//  InvoicesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI
import Combine
import BarChart
import RCPreferences

enum Section: Int {
    case invoice
    case report
}

enum ViewState {
    case noProjects
    case noInvoices
    case charts(ChartConfiguration, ChartConfiguration)
    case newInvoice(InvoiceStore)
    case invoice(InvoiceStore)
    case deleteInvoice(InvoiceFolder)
    case company(CompanyData?)
    case report(ReportStore)
    case error(String, String)
}

protocol ContentStoreProtocol: AnyObject {
    func didDeleteInvoice()
    func didSaveInvoice(_ folder: InvoiceFolder)
}

final class ContentStore: ObservableObject {
    
    @Published var viewState: ViewState = .noProjects
    @Published var invoiceStore: InvoiceStore?
    @Published var reportStore: ReportStore?
    var currentInvoiceData: InvoiceData? {
        didSet {
            if let project = selectedProject, let data = currentInvoiceData {
                invoiceStore = InvoiceStore(project: project, data: data)
                reportStore = ReportStore(project: project, data: data)
            } else {
                invoiceStore = nil
                reportStore = nil
            }
        }
    }
    @Published var projectName: String = ""
    @Published var invoiceName: String = ""
    @Published var section: Section = .invoice
    @Published var selectedProject: Project?
    @Published var totalPrice: String = ""
    var priceChartConfig = ChartConfiguration()
    var rateChartConfig = ChartConfiguration()
    var priceChartEntries: [ChartDataEntry] = []
    var rateChartEntries: [ChartDataEntry] = []
    private var pref = RCPreferences<UserPreferences>()
    weak var delegate: ContentStoreProtocol?
    
    init() {
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
}

extension ContentStore {
    
    func showChart (_ prices: [ChartDataEntry]?, _ rates: [ChartDataEntry]?) {
        DispatchQueue.main.async {
            if let prices = prices, let rates = rates {
                self.priceChartEntries = prices.reversed()
                self.rateChartEntries = rates.reversed()
            }
            self.priceChartConfig.data.entries = self.priceChartEntries
            self.rateChartConfig.data.entries = self.rateChartEntries
            self.viewState = .charts(self.priceChartConfig, self.rateChartConfig)
            // Bug in charts, need to set the data twice
            DispatchQueue.main.async {
                self.priceChartConfig.data.entries = self.priceChartEntries
                self.rateChartConfig.data.entries = self.rateChartEntries
                self.viewState = .charts(self.priceChartConfig, self.rateChartConfig)
            }
        }
    }
    
    func showSection (_ section: Section) {
        self.section = section
        switch section {
            case .invoice:
                viewState = .invoice(invoiceStore!)
            case .report:
                viewState = .report(reportStore!)
        }
    }
    
    func generateNewInvoice (using invoice: InvoiceFolder?) {
        guard let project = selectedProject else {
            return
        }
        InvoicesManager.shared.generateNewInvoice(in: project, using: invoice) { invoiceFolder, invoiceData in
            self.section = .invoice
//            self.selectedInvoice = invoiceFolder
            self.invoiceName = invoiceFolder.name
            self.currentInvoiceData = invoiceData
            guard let store = self.invoiceStore else {
                return
            }
            self.viewState = .newInvoice(store)
        }
    }
    
    func showInvoice() {
        guard let store = self.invoiceStore else {
            return
        }
        viewState = .invoice(store)
    }
    
    func save() {
        switch section {
            case .invoice:
                invoiceStore?.save() { invoiceFolder in
                    if let folder = invoiceFolder {
                        self.delegate?.didSaveInvoice(folder)
                    }
                }
            case .report:
                reportStore?.save()
        }
    }
    
    func export (isPdf: Bool) {
        save()
        switch section {
            case .invoice:
                invoiceStore?.export(isPdf: isPdf)
            case .report:
                reportStore?.export(isPdf: isPdf)
        }
    }
}

extension ContentStore {
    
    func deleteInvoice (_ invoice: InvoiceFolder) {
        #if os(iOS)
            
        #else
        AppFilesManager.default.executeInSelectedDir { url in
            let invoiceUrl = url.appendingPathComponent(selectedProject?.name ?? "").appendingPathComponent(invoice.name)
            do {
                try FileManager.default.removeItem(at: invoiceUrl)
                delegate?.didDeleteInvoice()
            } catch {
                
            }
        }
        #endif
    }
}
