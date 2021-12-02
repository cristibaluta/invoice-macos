//
//  InvoicesManager.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.11.2021.
//

import Foundation

class InvoicesManager {
    
    static let shared = InvoicesManager()
    
    func getInvoices (for project: Project, completion: (URL, [InvoiceFolder]) -> Void) {
        
        SandboxManager.executeInSelectedDir { url in
            let projectUrl = url.appendingPathComponent(project.name)
            do {
                var folders = try FileManager.default.contentsOfDirectory(atPath: projectUrl.path)
                folders.sort(by: {$0 > $1})
                let invoices: [InvoiceFolder] = folders.compactMap({
                    let comps: [String] = $0.components(separatedBy: "-")
                    if let dateComp = comps.first, let date = Date(yyyyMMdd: dateComp) {
                        let invoiceNrComp = comps.last ?? ""
                        return InvoiceFolder(date: date, invoiceNr: invoiceNrComp, name: $0)
                    } else {
                        return nil
                    }
                })
                completion(projectUrl, invoices)
            }
            catch {
                completion(projectUrl, [])
            }
        }
    }
    
    func generateNewInvoice (in project: Project, using invoice: InvoiceFolder?, completion: (InvoiceFolder, InvoiceData) -> Void) {
        SandboxManager.executeInSelectedDir { url in
            do {
                /// Read data from last invoice
                if let lastInvoice = invoice {
                    let lastInvoiceUrl = url.appendingPathComponent(project.name).appendingPathComponent(lastInvoice.name)
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
                    completion(invoiceFolder, invoice)
                } else {
                    // Empty invoice
                    let invoiceFolder = InvoiceFolder(date: Date(),
                                                      invoiceNr: "",
                                                      name: Date().yyyyMMdd)
                    completion(invoiceFolder, emptyInvoiceData)
                }
            } catch {
                print("\(error)")
                let invoiceFolder = InvoiceFolder(date: Date(),
                                                  invoiceNr: "",
                                                  name: Date().yyyyMMdd)
                completion(invoiceFolder, emptyInvoiceData)
            }
        }
    }
    
    var emptyInvoiceData: InvoiceData {
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
}
