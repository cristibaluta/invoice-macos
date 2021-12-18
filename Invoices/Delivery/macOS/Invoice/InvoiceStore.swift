//
//  InvoiceStore.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.11.2021.
//

import SwiftUI

class InvoiceStore: ObservableObject {
    
    var invoicePrintData: Data?
    var project: Project
    var data: InvoiceData
    @Published var html: String
    @Published var editingStore: InvoiceEditingStore
    
    init (project: Project, data: InvoiceData) {
        self.html = ""
        self.project = project
        self.data = data
        self.editingStore = InvoiceEditingStore(data: data)
        calculate()
    }
    
    func calculate() {
        AppFilesManager.executeInSelectedDir { url in
            /// Get template
            let projectUrl = url.appendingPathComponent(project.name)
            let templateUrl = projectUrl.appendingPathComponent("templates")
            guard var template = try? String(contentsOfFile: templateUrl.appendingPathComponent("template_invoice.html").path),
                  let templateRow = try? String(contentsOfFile: templateUrl.appendingPathComponent("template_invoice_row.html").path) else {
                  html = "Error: Templates are missing!"
                return
            }
            
            data.calculate()
            
            // Replace
            template = data.toHtmlUsingTemplate(template)
            
            /// Add rows
            var i = 1
            var rows = ""
            for product in data.products {
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
    
    func save (completion: @escaping (InvoiceFolder?) -> Void) {
        AppFilesManager.executeInSelectedDir { url in
            do {
                // Generate folder if none exists
                let invoiceNr = "\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
                let folderName = "\(data.date.yyyyMMdd)-\(invoiceNr)"
                let projectUrl = url.appendingPathComponent(project.name)
                let invoiceUrl = projectUrl.appendingPathComponent(folderName)
                try FileManager.default.createDirectory(at: invoiceUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                // Save json
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let invoiceJsonUrl = invoiceUrl.appendingPathComponent("data.json")
                let jsonData = try encoder.encode(data)
                try jsonData.write(to: invoiceJsonUrl)
                completion(InvoiceFolder(date: data.date, invoiceNr: invoiceNr, name: folderName))
            }
            catch {
                print(error)
                completion(nil)
            }
        }
    }
    
    func export (isPdf: Bool) {
#if os(iOS)
        print("exporting for ios")
#else
        let fileName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).\(isPdf ? "pdf" : "html")"
        let panel = NSSavePanel()
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = fileName
        panel.begin { result in
            if result == NSApplication.ModalResponse.OK {
                if let url = panel.url {
                    do {
                        if isPdf {
                            try self.invoicePrintData?.write(to: url)
                        } else {
                            try self.html.write(to: url, atomically: true, encoding: .utf8)
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
#endif
    }
}
