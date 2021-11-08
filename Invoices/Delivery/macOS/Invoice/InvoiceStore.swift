//
//  InvoiceStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.11.2021.
//

import SwiftUI

class InvoiceStore: ObservableObject {
    
    var invoicePrintData: Data?
    var data: InvoiceData
    var invoiceDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(data) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    @Published var html: String
    
    
    init (data: InvoiceData) {
        self.html = ""
        self.data = data
        calculate()
    }
    
    func calculate() {
        SandboxManager.executeInSelectedDir { url in
            /// Get template
            let templateUrl = url.appendingPathComponent("templates")
            guard var template = try? String(contentsOfFile: templateUrl.appendingPathComponent("template_invoice.html").path),
                  let templateRow = try? String(contentsOfFile: templateUrl.appendingPathComponent("template_invoice_row.html").path) else {
                  html = "Error: Templates are missing!"
                return
            }
            
            /// Add new invoice data to the template
            /// Convert the data to dictionary
            for (key, value) in (invoiceDictionary ?? [:]) {
                guard key != "amount" && key != "amount_total" else {
                    continue
                }
                if key == "invoice_date", let date = Date(yyyyMMdd: value as? String ?? "") {
                    template = template.replacingOccurrences(of: "::\(key)::", with: "\(date.ddMMMyyyy)")
                }
                else if key == "contractor", let dic = value as? [String: Any] {
                    for (k, v) in dic {
                        template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                    }
                } else if key == "client", let dic = value as? [String: Any] {
                    for (k, v) in dic {
                        template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                    }
                } else {
                    template = template.replacingOccurrences(of: "::\(key)::", with: "\(value)")
                }
            }
            
            /// Calculate the amount
            var amount_total = 0.0
            var products = [InvoiceProduct]()
            
            for var product in data.products {
                let amount_per_unit = product.rate * product.exchange_rate
                let amount = product.units * amount_per_unit
                amount_total += amount + amount * data.tva / 100
                
                product.amount_per_unit = amount_per_unit
                product.amount = amount
                products.append(product)
            }
            
            data.amount_total = amount_total
            
            /// Add rows
            var i = 1
            var rows = ""
            for product in products {
                var row = templateRow.replacingOccurrences(of: "::nr::", with: "\(i)")
                row = row.replacingOccurrences(of: "::product::", with: product.product_name)
                row = row.replacingOccurrences(of: "::rate::",
                                               with: "\(product.rate.stringFormatWith2Digits)")
                row = row.replacingOccurrences(of: "::exchange_rate::",
                                               with: "\(product.exchange_rate.stringFormatWith4Digits)")
                row = row.replacingOccurrences(of: "::units_name::", with: product.units_name)
                row = row.replacingOccurrences(of: "::units::",
                                               with: "\(product.units.stringFormatWith2Digits)")
                row = row.replacingOccurrences(of: "::amount_per_unit::",
                                               with: "\(product.amount_per_unit.stringFormatWith4Digits)")
                row = row.replacingOccurrences(of: "::amount::",
                                               with: "\(product.amount.stringFormatWith2Digits)")
                
                rows += row
                i += 1
            }
            
            template = template.replacingOccurrences(of: "::rows::", with: rows)
            template = template.replacingOccurrences(of: "::amount::",
                                                     with: "\(data.amount_total.stringFormatWith2Digits)")
            template = template.replacingOccurrences(of: "::amount_total::",
                                                     with: "\(data.amount_total.stringFormatWith2Digits)")
            
            self.html = template
        }
    }
    
    func save() {
        SandboxManager.executeInSelectedDir { url in
            do {
                // Generate folder if none exists
                let invoiceUrl = url.appendingPathComponent(data.date.yyyyMMdd)
                try FileManager.default.createDirectory(at: invoiceUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                // Save json
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let invoiceJsonUrl = invoiceUrl.appendingPathComponent("data.json")
                let jsonData = try encoder.encode(data)
                try jsonData.write(to: invoiceJsonUrl)
                
                // Save invoice html + pdf
                let invoiceHtmlUrl = invoiceUrl.appendingPathComponent("invoice.html")
                try html.write(to: invoiceHtmlUrl, atomically: true, encoding: .utf8)
                let invoicePdfUrl = invoiceUrl.appendingPathComponent("invoice-\(data.invoice_series)\(data.invoice_nr)-\(data.date.yyyyMMdd).pdf")
                try invoicePrintData?.write(to: invoicePdfUrl)
            }
            catch {
                print(error)
            }
        }
    }
}
