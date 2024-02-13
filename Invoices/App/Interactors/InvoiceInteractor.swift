//
//  InvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine

enum InvoiceTemplateType: String {
    case html
    case xml
}

class InvoiceInteractor {

    private let repository: Repository
    private let project: Project

    init (repository: Repository, project: Project) {
        print("init InvoiceInteractor")
        self.repository = repository
        self.project = project
    }

    func buildHtml (data: InvoiceData) -> AnyPublisher<String, Never> {
        return fillTemplates(type: .html, with: data)
    }

    func save (data: InvoiceData, pdfData: Data?) -> AnyPublisher<Invoice, Never> {

        // Generate folder if none exists
        let invoiceNr = "\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
        let invoiceFolderName = "\(data.date.yyyyMMdd)-\(invoiceNr)"
        let invoicePath = "\(project.name)/\(invoiceFolderName)"
        let writeFolderPublisher = repository.writeFolder(at: invoicePath)

        // Save json data
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(data)
        let invoiceJsonPath = "\(invoicePath)/data.json"
        let writeJsonPublisher = repository.writeFile(jsonData, at: invoiceJsonPath)

        // Save xml for ANAF
        let writeXmlPublisher = fillTemplates(type: .xml, with: data)
            .map { xmlString in
                let xmlData = xmlString.data(using: .utf8)!
                let invoiceXmlPath = "\(invoicePath)/data.xml"
                return self.repository.writeFile(xmlData, at: invoiceXmlPath)
            }

        // Save pdf
        let pdfName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
        let pdfPath = "\(invoicePath)/\(pdfName)"
        let writePdfPublisher = repository.writeFile(pdfData!, at: pdfPath)

        let publisher = Publishers.Zip4(writeFolderPublisher, writeJsonPublisher, writeXmlPublisher, writePdfPublisher)
            .map { x in
                return Invoice(date: data.date, invoiceNr: invoiceNr, name: invoiceFolderName)
            }
            .eraseToAnyPublisher()

        return publisher
    }

    private func fillTemplates (type: InvoiceTemplateType, with data: InvoiceData) -> AnyPublisher<String, Never> {

        return readInvoiceTemplates(type: type)
            .map { templates in
                /// 0 = page template
                /// 1 = row template

                var template = templates.0
                let templateRow = templates.1

                let dict = data.toDictionary()

                for (key, value) in dict {
                    if key == "amount_total" || key == "amount_total_vat", let amount = Decimal(string: value as? String ?? "") {
                        // Format the money values
                        let formattedAmount = type == .html ? amount.stringValue_grouped2 : amount.stringValue_2
                        template = template.replacingOccurrences(of: "::\(key)::", with: "\(formattedAmount)")
                    }
                    else if key == "invoice_date" || key == "invoiced_period", let date = Date(yyyyMMdd: value as? String ?? "") {
                        let formattedDate = type == .html ? date.mediumDate : date.yyyyMMdd_dashes
                        template = template.replacingOccurrences(of: "::\(key)::", with: "\(formattedDate)")
                    }
                    else if key == "invoice_nr" {
                        // Prefix the invoice nr with zeroes
                        template = template.replacingOccurrences(of: "::\(key)::", with: data.invoice_nr.prefixedWith0)
                    }
                    else if key == "contractor" || key == "client", let dic = value as? [String: Any] {
                        // Contractor and client have a prefix
                        for (k, v) in dic {
                            template = template.replacingOccurrences(of: "::\(key)_\(k)::", with: "\(v)")
                        }
                    }
                    else {
                        template = template.replacingOccurrences(of: "::\(key)::", with: "\(value)")
                    }
                }

                /// Add product rows
                var i = 1
                var rows = ""
                for product in data.products {
                    var row = templateRow.replacingOccurrences(of: "::nr::", with: "\(i)")
                    row = row.replacingOccurrences(of: "::product::",
                                                   with: type == .html ? product.product_name : product.product_name.alphanumeric)
                    row = row.replacingOccurrences(of: "::rate::",
                                                   with: "\(product.rate.stringValue_grouped2)")
                    row = row.replacingOccurrences(of: "::exchange_rate::",
                                                   with: "\(product.exchange_rate.stringValue_grouped4)")
                    row = row.replacingOccurrences(of: "::units_name::",
                                                   with: product.units_name)
                    row = row.replacingOccurrences(of: "::units::",
                                                   with: "\(product.units.stringValue_grouped2)")
                    row = row.replacingOccurrences(of: "::amount_per_unit::",
                                                   with: "\(product.amount_per_unit.stringValue_grouped4)")
                    row = row.replacingOccurrences(of: "::amount::",
                                                   with: "\(type == .html ? product.amount.stringValue_grouped2 : product.amount.stringValue_2)")

                    rows += row
                    i += 1
                }
                template = template.replacingOccurrences(of: "::rows::", with: rows)
                return template
            }
            .eraseToAnyPublisher()
    }

    private func readInvoiceTemplates (type: InvoiceTemplateType) -> AnyPublisher<(String, String), Never> {

        let templatesPath = "\(project.name)/templates"

        let template_invoice = repository
            .readFile(at: "\(templatesPath)/template_invoice.\(type.rawValue)")
            .map { String(decoding: $0, as: UTF8.self) }

        let template_invoice_row = repository
            .readFile(at: "\(templatesPath)/template_invoice_row.\(type.rawValue)")
            .map { String(decoding: $0, as: UTF8.self) }

        return Publishers.Zip(template_invoice, template_invoice_row)
            .eraseToAnyPublisher()
    }

}
