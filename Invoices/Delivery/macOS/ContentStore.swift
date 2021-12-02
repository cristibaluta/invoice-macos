//
//  InvoicesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI
import Combine
import BarChart

enum DrawerState {
    case noProjects
    case projects([Project])
    case invoices([InvoiceFolder])
}

enum ViewState {
    case noProjects
    case noInvoices
    case charts(ChartConfiguration, ChartConfiguration)
    case invoice(InvoiceStore)
    case report(ReportStore)
    case error(String, String)
}

final class ContentStore: ObservableObject {
    
    @Published var drawerState: DrawerState = .noProjects
    @Published var viewState: ViewState = .noProjects
    
    @Published var projects: [Project] = []
    @Published var invoices: [InvoiceFolder] = []
    
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
    @Published var section: Int = 0
    @Published var selectedProject: Project?
    @Published var selectedInvoice: InvoiceFolder?
    @Published var totalPrice: String = ""
    var priceChartConfig = ChartConfiguration()
    var rateChartConfig = ChartConfiguration()
    var priceChartEntries: [ChartDataEntry] = []
    var rateChartEntries: [ChartDataEntry] = []
    
    init() {
//        History().clear()
        reloadProjects()
        
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
    
    func reloadProjects() {
        ProjectsManager.shared.getProjects() { projects in
            self.projects = projects
            if let firstProject = projects.first {
                self.drawerState = .projects(projects)
                self.viewState = .noProjects
                self.loadProject(firstProject)
            } else {
                self.drawerState = .noProjects
                self.viewState = .noProjects
            }
        }
    }
    
    func createProject (_ name: String) {
        guard !name.isEmpty else {
            return
        }
        ProjectsManager.shared.createProject(name) { project in
            self.reloadProjects()
        }
    }
    
    func loadProject(_ project: Project) {
        
        selectedProject = project
        
        InvoicesManager.shared.getInvoices(for: project) { projectUrl, invoices in
            self.invoices = invoices
            var prices = [ChartDataEntry]()
            var rates = [ChartDataEntry]()
            var total: Decimal = 0
            for invoice in invoices {
                // Load all invoices data and display a chart
                let invoiceUrl = projectUrl.appendingPathComponent(invoice.name).appendingPathComponent("data.json")
                do {
                    let jsonData = try Data(contentsOf: invoiceUrl)
                    let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                    let price = ChartDataEntry(x: "\(invoice.invoice_nr)", y: invoice.amount_total_vat.doubleValue)
                    total += invoice.amount_total_vat
                    prices.append(price)
                    let rate = ChartDataEntry(x: "\(invoice.invoice_nr)", y: invoice.products[0].rate.doubleValue)
                    rates.append(rate)
                    showChart(prices, rates)
                } catch {
                    print("\(error)")
                }
            }
            totalPrice = total.stringValue_grouped2
            drawerState = .invoices(invoices)
            if invoices.isEmpty {
                viewState = .noInvoices
            }
        }
    }
    
    func loadInvoice(_ invoice: InvoiceFolder) {
        selectedInvoice = invoice
        invoiceName = invoice.name
        
        SandboxManager.executeInSelectedDir { url in
            let projectUrl = url.appendingPathComponent(selectedProject?.name ?? "")
            let invoiceUrl = projectUrl.appendingPathComponent(invoice.name).appendingPathComponent("data.json")
            do {
                let jsonData = try Data(contentsOf: invoiceUrl)
                let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                self.currentInvoiceData = invoice
                self.showSection(section)
            } catch {
                viewState = .error("Error parsing json data", "\(error)")
            }
        }
    }
}

extension ContentStore {
    
    func showChart(_ prices: [ChartDataEntry], _ rates: [ChartDataEntry]) {
        DispatchQueue.main.async {
            self.priceChartEntries = prices.reversed()
            self.rateChartEntries = rates.reversed()
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
    
    func showSection (_ section: Int) {
        print(section)
        self.section = section
        switch section {
            case 0:
                viewState = .invoice(invoiceStore!)
            case 1:
                viewState = .report(reportStore!)
            default: break
        }
    }
    
    func generateNewInvoice() {
        guard let project = selectedProject else {
            return
        }
        InvoicesManager.shared.generateNewInvoice(in: project, using: invoices.first) { invoiceFolder, invoiceData in
            self.section = 0
            self.selectedInvoice = invoiceFolder
            self.invoiceName = invoiceFolder.name
            self.currentInvoiceData = invoiceData
            if let store = self.invoiceStore {
                viewState = .invoice(store)
            }
        }
    }
    
//    func openProject() {
//        let panel = NSOpenPanel()
//        panel.canChooseFiles = false
//        panel.canChooseDirectories = true
//        panel.canCreateDirectories = true
//        panel.allowsMultipleSelection = false
//        panel.title = "Chose a destination directory for your invoices"
//        if panel.runModal() == .OK {
//            if let url = panel.urls.first {
//                self.reloadProjects()
//            }
//        }
//    }
    
    func save() {
        switch section {
            case 0:
                invoiceStore?.save() { invoiceFolder in
                    if let folder = invoiceFolder {
                        if !self.invoices.contains(where: {$0.name == folder.name}) {
                            self.invoices.insert(folder, at: 0)
                        }
                    }
                }
            case 1:
                reportStore?.save()
            default: break
        }
    }
    
    func exportInvoice(isPdf: Bool) {
        save()
        invoiceStore?.export(isPdf: isPdf)
    }
    
    func exportReport(isPdf: Bool) {
        save()
        reportStore?.export(isPdf: isPdf)
    }
}

extension ContentStore {
    
    func showInFinder (_ project: Project) {
        SandboxManager.executeInSelectedDir { url in
            let url = url.appendingPathComponent(project.name)
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        }
    }
    
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
