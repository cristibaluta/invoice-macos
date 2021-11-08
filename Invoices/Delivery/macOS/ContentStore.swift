//
//  InvoicesStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//

import SwiftUI
import Combine

struct Invoice: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var name: String
}

final class ContentStore: ObservableObject {
    
    @Published var invoices: [Invoice] = []
    @Published var currentInvoiceStore: InvoiceStore?
    @Published var currentReportStore: ReportStore?
    var currentInvoiceData: InvoiceData? {
        didSet {
            if let data = currentInvoiceData {
                if currentInvoiceStore == nil {
                    currentInvoiceStore = InvoiceStore(data: data)
                    currentReportStore = ReportStore(data: data)
                } else {
                    currentInvoiceStore?.data = data
                    currentInvoiceStore?.calculate()
                    currentReportStore?.data = data
                    currentReportStore?.calculate()
                }
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
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
                var list = [Invoice]()
                for file in files.sorted().reversed() {
                    if let date = Date(yyyyMMdd: file) {
                        list.append(Invoice(date: date, name: file))
                    }
                }
                showInvoices(list)
            } catch {
                print("\(error)")
            }
        }
    }
}

extension ContentStore {
    
    func showInvoices(_ invoices: [Invoice]) {
        self.invoices = invoices
    }
    
    func showInvoice(_ invoice: Invoice) {
        SandboxManager.executeInSelectedDir { url in
            let invoiceUrl = url.appendingPathComponent(invoice.name)
            do {
                let jsonData = try Data(contentsOf: invoiceUrl.appendingPathComponent("data.json"))
                let jsonObject = try JSONDecoder().decode(InvoiceData.self, from: jsonData)
                self.currentInvoiceData = jsonObject
            } catch {
                print(error)
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
                    invoice.invoice_date = (Date(yyyyMMdd: invoice.invoice_date)?.nextMonth().endOfMonth() ?? Date()).yyyyMMdd
                    
                    self.currentInvoiceData = invoice
                } else {
                    self.currentInvoiceData = emptyInvoiceData
                }
            } catch {
                print("\(error)")
                self.currentInvoiceData = emptyInvoiceData
            }
        }
    }
    
    func initProject (at url: URL) {
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
                    try FileManager.default.copyItem(atPath: bundlePath!, toPath: destPath)
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
                           tva: 0,
                           amount_total: 0)
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
                currentInvoiceStore?.save()
            case 1:
                currentReportStore?.save()
            default: break
        }
    }
}

extension ContentStore {
    func showInFinder (_ invoice: Invoice) {
        SandboxManager.executeInSelectedDir { url in
            let invoiceUrl = url.appendingPathComponent(invoice.name)
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: invoiceUrl.path)
        }
    }
    private func showInFinderAndSelectLastComponent(of url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

struct ContentStore_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
