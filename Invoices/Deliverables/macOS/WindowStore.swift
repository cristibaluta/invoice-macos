//
//  WindowStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 05.01.2022.
//

import SwiftUI
import Combine
import BarChart
import RCPreferences

enum SidebarState {
    case noProjects
    case projects([Project])
    case invoices([InvoiceFolder])
}

final class WindowStore: ObservableObject {
    
    @Published var sidebarState: SidebarState = .noProjects
    @Published var projects: [Project] = []
    @Published var invoices: [InvoiceFolder] = []
    @Published var projectName: String = ""
    @Published var invoiceName: String = ""
    @Published var selectedProject: Project? {
        didSet {
            pref.set(selectedProject?.name ?? "", forKey: .lastProject)
            contentStore.selectedProject = selectedProject
        }
    }
    @Published var selectedInvoice: InvoiceFolder? {
        didSet {
            if let invoice = selectedInvoice {
                loadInvoice(invoice)
            }
        }
    }
    
    private var pref = RCPreferences<UserPreferences>()
    var contentStore = ContentStore()
    
    init() {
        contentStore.delegate = self
        reloadProjects()
    }
    
    func reloadProjects() {
        
        ProjectsManager.shared.getProjects() { projects in
            self.projects = projects
            
            if let lastProject = projects.first(where: {$0.name == pref.string(.lastProject)}) ?? projects.first {
                self.sidebarState = .projects(projects)
                #if os(macOS)
                self.contentStore.viewState = .noProjects
                self.loadProject(lastProject)
                #endif
            } else {
                self.sidebarState = .noProjects
                #if os(macOS)
                self.contentStore.viewState = .noProjects
                #endif
            }
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
                if FileManager.default.fileExists(atPath: invoiceUrl.path) {
                    print("File exists \(invoiceUrl.path)")
                } else {
                    print("Start downloading \(invoiceUrl.path)")
                    do {
                        try FileManager.default.startDownloadingUbiquitousItem(at: invoiceUrl)
                    } catch {
                        print("Error while loading Backup File \(error)")
                    }
                }
                do {
                    let jsonData = try Data(contentsOf: invoiceUrl)
                    let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                    let price = invoice.amount_total_vat.doubleValue// + Double.random(in: 0..<10000)
                    total += invoice.amount_total_vat
                    let priceEntry = ChartDataEntry(x: "\(invoice.invoice_nr)", y: price)
                    prices.append(priceEntry)
                    let rate = invoice.products[0].rate.doubleValue// + Double.random(in: 0..<100)
                    let rateEntry = ChartDataEntry(x: "\(invoice.invoice_nr)", y: rate)
                    rates.append(rateEntry)
//                    showChart(prices, rates)
                } catch {
                    print("\(error)")
                }
            }
//            totalPrice = total.stringValue_grouped2
            sidebarState = .invoices(invoices)
//            if invoices.isEmpty {
//                viewState = .noInvoices
//            }
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
    
    func loadInvoice(_ invoice: InvoiceFolder) {
        invoiceName = invoice.name
        
        AppFilesManager.default.executeInSelectedDir { url in
            let projectUrl = url.appendingPathComponent(selectedProject?.name ?? "")
            let invoiceUrl = projectUrl.appendingPathComponent(invoice.name).appendingPathComponent("data.json")
            do {
                let jsonData = try Data(contentsOf: invoiceUrl)
                let invoice = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                #if os(iOS)
                                
                #else
                contentStore.currentInvoiceData = invoice
                contentStore.showSection(.invoice)
                #endif
            } catch {
                contentStore.viewState = .error("Error parsing json data", "\(error)")
            }
        }
    }
    
    func generateNewInvoice() {
        contentStore.generateNewInvoice(using: invoices.first)
    }
}

extension WindowStore {
    
    func showInFinder (_ invoice: InvoiceFolder) {
        #if os(iOS)
            
        #else
        AppFilesManager.default.executeInSelectedDir { url in
            let invoiceUrl = url.appendingPathComponent(selectedProject?.name ?? "").appendingPathComponent(invoice.name)
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: invoiceUrl.path)
        }
        #endif
    }
}

extension WindowStore: ContentStoreProtocol {
    
    func didDeleteInvoice() {
        reloadProjects()
    }
    
    func didSaveInvoice(_ folder: InvoiceFolder) {
        if !self.invoices.contains(where: {$0.name == folder.name}) {
            self.invoices.insert(folder, at: 0)
        }
    }
}
