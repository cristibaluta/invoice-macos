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
            
            var products = [InvoiceProduct]()
            
            /// Calculate the amount
            if data.isAmountTotalProvided == true {
                // We know the total amount
                // We calculate the units
                data.amount_total_vat = data.amount_total + data.amount_total * data.vat / 100

                for var product in data.products {
                    product.amount_per_unit = product.rate * product.exchange_rate
                    product.units = data.amount_total / product.amount_per_unit
                    product.amount = data.amount_total
                    products.append(product)
                }
            }
            else {
                // We know the units
                // We calculate the total amount
                var amount_total: Decimal = 0.0
                
                for var product in data.products {
                    let amount_per_unit = product.rate * product.exchange_rate
                    let amount = product.units * amount_per_unit
                    amount_total += amount
                    
                    product.amount_per_unit = amount_per_unit
                    product.amount = amount
                    products.append(product)
                }
                
                data.amount_total = amount_total
                data.amount_total_vat = data.amount_total + data.amount_total * data.vat / 100
            }
            
            // Replace
            template = data.toHtmlUsingTemplate(template)
            
            /// Add rows
            var i = 1
            var rows = ""
            for product in products {
                var row = templateRow.replacingOccurrences(of: "::nr::", with: "\(i)")
                row = row.replacingOccurrences(of: "::product::", with: product.product_name)
                row = row.replacingOccurrences(of: "::rate::",
                                               with: "\(product.rate.stringValue_grouped2)")
                row = row.replacingOccurrences(of: "::exchange_rate::",
                                               with: "\(product.exchange_rate.stringValue_grouped4)")
                row = row.replacingOccurrences(of: "::units_name::", with: product.units_name)
                row = row.replacingOccurrences(of: "::units::",
                                               with: "\(product.units.stringValue_grouped2)")
                row = row.replacingOccurrences(of: "::amount_per_unit::",
                                               with: "\(product.amount_per_unit.stringValue_grouped4)")
                row = row.replacingOccurrences(of: "::amount::",
                                               with: "\(product.amount.stringValue_grouped2)")
                
                rows += row
                i += 1
            }
            template = template.replacingOccurrences(of: "::rows::", with: rows)
            
            self.html = template
        }
    }
    
    func save() {
        SandboxManager.executeInSelectedDir { url in
            do {
                // Generate folder if none exists
                let folderName = "\(data.date.yyyyMMdd)-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
                let invoiceUrl = url.appendingPathComponent(folderName)
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
//                let invoiceHtmlUrl = invoiceUrl.appendingPathComponent("invoice.html")
//                try html.write(to: invoiceHtmlUrl, atomically: true, encoding: .utf8)
                let pdfName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
                let invoicePdfUrl = invoiceUrl.appendingPathComponent(pdfName)
                try invoicePrintData?.write(to: invoicePdfUrl)
            }
            catch {
                print(error)
            }
        }
    }
}
