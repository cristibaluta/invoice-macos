//
//  InvoicesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI
import Combine
import BarChart

final class ContentStore: ObservableObject {
    
    @Published var invoices: [InvoiceFolder] = []
    @Published var currentInvoiceStore: InvoiceStore?
    @Published var currentReportStore: ReportStore?
    var currentInvoiceData: InvoiceData? {
        didSet {
            if let data = currentInvoiceData {
                currentInvoiceStore = InvoiceStore(data: data)
                currentReportStore = ReportStore(data: data)
            } else {
                currentInvoiceStore = nil
                currentReportStore = nil
            }
        }
    }
    @Published var errorMessage: (String, String)?
    @Published var hasFolderSelected: Bool = false
    @Published var isEditing: Bool = false
    @Published var section: Int = 0
    @Published var invoiceName: String = ""
    @Published var selectKeeper: InvoiceFolder?
    var chartConfig = ChartConfiguration()
    var rateChartConfig = ChartConfiguration()
    @Published var chartEntries: [ChartDataEntry] = []
    @Published var rateChartEntries: [ChartDataEntry] = []
    
    init() {
//        History().clear()
        reloadData()
    }
    
    func reloadData() {
        guard History().getLastProjectDir() != nil else {
            hasFolderSelected = false
            return
        }
        hasFolderSelected = true
        // Read all invoices from current directory
        SandboxManager.executeInSelectedDir { url in
            do {
                let folders = try FileManager.default.contentsOfDirectory(atPath: url.path)
                var list = [InvoiceFolder]()
                var prices = [ChartDataEntry]()
                var rates = [ChartDataEntry]()
                
                for folder in folders.sorted().reversed() {
                    let comps: [String] = folder.components(separatedBy: "-")
                    if let dateComp = comps.first, let date = Date(yyyyMMdd: dateComp) {
                        let invoiceNrComp = comps.last ?? ""
                        let invoiceFolder = InvoiceFolder(date: date, invoiceNr: invoiceNrComp, name: folder)
                        list.append(invoiceFolder)
                        // Load data to display in chart
                        let invoiceUrl = url.appendingPathComponent(invoiceFolder.name)
                        do {
                            let jsonData = try Data(contentsOf: invoiceUrl.appendingPathComponent("data.json"))
                            let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                            let price = ChartDataEntry(x: "\(invoice.invoice_nr)", y: invoice.amount_total_vat.doubleValue)
                            prices.append(price)
                            let rate = ChartDataEntry(x: "\(invoice.invoice_nr)", y: invoice.products[0].rate.doubleValue)
                            rates.append(rate)
                        } catch {
                            
                        }
                    }
                }
                showInvoices(list)
                showChart(prices, rates)
            } catch {
                print("\(error)")
            }
        }
    }
}

extension ContentStore {
    
    func showInvoices(_ invoices: [InvoiceFolder]) {
        self.invoices = invoices
    }
    
    func showChart(_ prices: [ChartDataEntry], _ rates: [ChartDataEntry]) {
        DispatchQueue.main.async {
            self.chartEntries = prices.reversed()
            self.rateChartEntries = rates.reversed()
            self.chartConfig.data.entries = self.chartEntries
            self.rateChartConfig.data.entries = self.rateChartEntries
            DispatchQueue.main.async {
                self.chartConfig.data.entries = self.chartEntries
                self.rateChartConfig.data.entries = self.rateChartEntries
            }
        }
    }
    
    func showInvoice(_ invoice: InvoiceFolder) {
        print("Show invoice \(invoice)")
        selectKeeper = invoice
        invoiceName = invoice.name
        
        SandboxManager.executeInSelectedDir { url in
            let invoiceUrl = url.appendingPathComponent(invoice.name)
            do {
                let jsonData = try Data(contentsOf: invoiceUrl.appendingPathComponent("data.json"))
                let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                self.currentInvoiceData = nil
                self.currentInvoiceData = invoice
            } catch {
                self.isEditing = false
                self.currentInvoiceData = nil
                self.errorMessage = ("Error parsing data.json", "\(error)")
            }
        }
    }
    
    func showSection (_ section: Int) {
        self.section = section
    }
    
    func generateNewInvoice() {
        SandboxManager.executeInSelectedDir { url in
            do {
                /// Read data from last invoice
                if let lastInvoice = invoices.first {
                    let lastInvoiceUrl = url.appendingPathComponent(lastInvoice.name)
                    let jsonData = try Data(contentsOf: lastInvoiceUrl.appendingPathComponent("data.json"))
                    var invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                    /// Increase invoice nr
                    invoice.invoice_nr += 1
                    // Set invoice date to last working day of the next month
                    let nextDate = Date(yyyyMMdd: invoice.invoice_date)?.nextMonth().endOfMonth() ?? Date()
                    invoice.invoice_date = nextDate.yyyyMMdd
                    invoice.reports = []
                    
                    let invoiceFolder = InvoiceFolder(date: nextDate,
                                                      invoiceNr: "\(invoice.invoice_series)\(invoice.invoice_nr)",
                                                      name: "\(nextDate.yyyyMMdd)-\(invoice.invoice_series)\(invoice.invoice_nr.prefixedWith0)")
                    self.invoices.insert(invoiceFolder, at: 0)
                    self.section = 0
                    self.isEditing = true
                    self.selectKeeper = invoiceFolder
                    self.invoiceName = invoiceFolder.name
                    self.currentInvoiceData = invoice
                } else {
                    // Empty invoice
                    let invoiceFolder = InvoiceFolder(date: Date(),
                                                      invoiceNr: "",
                                                      name: Date().yyyyMMdd)
                    self.invoices.insert(invoiceFolder, at: 0)
                    self.section = 0
                    self.isEditing = true
                    self.selectKeeper = invoiceFolder
                    self.invoiceName = invoiceFolder.name
                    self.currentInvoiceData = emptyInvoiceData
                }
            } catch {
                print("\(error)")
                let invoiceFolder = InvoiceFolder(date: Date(),
                                                  invoiceNr: "",
                                                  name: Date().yyyyMMdd)
                self.invoices.insert(invoiceFolder, at: 0)
                self.section = 0
                self.isEditing = true
                self.selectKeeper = invoiceFolder
                self.invoiceName = invoiceFolder.name
                self.currentInvoiceData = emptyInvoiceData
            }
        }
    }
    
    func initProject (at url: URL) {
        currentInvoiceData = nil
        History().setLastProjectDir(url)
        SandboxManager.executeInSelectedDir { url in
            do {
                // Create templates folder
                let templateUrl = url.appendingPathComponent("templates")
                try FileManager.default.createDirectory(at: templateUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                // Copy templates from bundle
                let templates = ["template_invoice",
                                 "template_invoice_row",
                                 "template_report",
                                 "template_report_project",
                                 "template_report_row"]
                for template in templates {
                    let bundlePath = Bundle.main.path(forResource: template, ofType: ".html")
                    let destPath = templateUrl.appendingPathComponent("\(template).html").path
                    if !FileManager.default.fileExists(atPath: destPath) {
                        try FileManager.default.copyItem(atPath: bundlePath!, toPath: destPath)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    private var emptyInvoiceData: InvoiceData {
        return InvoiceData(invoice_series: "",
                           invoice_nr: 1,
                           invoice_date: Date().yyyyMMdd,
                           client: CompanyDetails(name: "",
                                                  orc: "",
                                                  cui: "",
                                                  address: "",
                                                  county: "",
                                                  bank_account: "",
                                                  bank_name: ""),
                           contractor: CompanyDetails(name: "",
                                                      orc: "",
                                                      cui: "",
                                                      address: "",
                                                      county: "",
                                                      bank_account: "",
                                                      bank_name: ""),
                           products: [InvoiceProduct(product_name: "",
                                                     rate: 0,
                                                     exchange_rate: 0,
                                                     units: 0,
                                                     units_name: "",
                                                     amount_per_unit: 0,
                                                     amount: 0)],
                           reports: [],
                           currency: "",
                           vat: 0,
                           amount_total: 0,
                           amount_total_vat: 0)
    }
    
    func edit() {
        switch section {
            case 0:
                isEditing.toggle()
            case 1:
                break
            default: break
        }
    }
    
    func save() {
        switch section {
            case 0:
                currentInvoiceStore?.save() { invoiceFolder in
                    if let folder = invoiceFolder {
                        if !self.invoices.contains(where: {$0.name == folder.name}) {
                            self.invoices.insert(folder, at: 0)
                        }
                    }
                }
            case 1:
                currentReportStore?.save()
            default: break
        }
    }
}

extension ContentStore {
    func showInFinder (_ invoice: InvoiceFolder) {
        SandboxManager.executeInSelectedDir { url in
            let invoiceUrl = url.appendingPathComponent(invoice.name)
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: invoiceUrl.path)
        }
    }
    private func showInFinderAndSelectLastComponent(of url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
