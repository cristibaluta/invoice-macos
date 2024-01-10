//
//  InvoicesInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine

class InvoicesInteractor {

    private let repository: Repository

    init (repository: Repository) {
        self.repository = repository
    }

    func refreshInvoicesList (for project: Project) -> AnyPublisher<[Invoice], Never> {

        return repository
            .readFolderContent(at: project.name)
            .compactMap { file in
                if file.hasPrefix(".") {
                    return nil
                }
                if file.hasSuffix(".json") {
                    return nil
                }
                let comps: [String] = file.components(separatedBy: "-")
                if let dateComp = comps.first, let date = Date(yyyyMMdd: dateComp) {
                    let invoiceNrComp = comps.last ?? ""
                    return Invoice(date: date, invoiceNr: invoiceNrComp, name: file)
                }
                return nil
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func readInvoice (for invoice: Invoice, in project: Project) -> AnyPublisher<InvoiceData, Never> {

        let invoicePath = "\(project.name)/\(invoice.name)/data.json"
        print(invoicePath)

        return repository
            .readFile(at: invoicePath)
            .decode(type: InvoiceData.self, decoder: JSONDecoder())
            .replaceError(with: InvoicesInteractor.emptyInvoiceData)
            .eraseToAnyPublisher()
    }

    func readInvoiceTemplates (in folder: Project) -> AnyPublisher<(String, String), Never> {

        let templatesPath = "\(folder.name)/templates"

        let template_invoice = repository
            .readFile(at: "\(templatesPath)/template_invoice.html")
            .map { String(decoding: $0, as: UTF8.self) }

        let template_invoice_row = repository
            .readFile(at: "\(templatesPath)/template_invoice_row.html")
            .map { String(decoding: $0, as: UTF8.self) }

        return Publishers.Zip(template_invoice, template_invoice_row)
            .eraseToAnyPublisher()
    }

    func saveInvoice (data: InvoiceData, pdfData: Data?, in project: Project) -> AnyPublisher<Invoice, Never> {

        // Generate folder if none exists
        let invoiceNr = "\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
        let invoiceFolderName = "\(data.date.yyyyMMdd)-\(invoiceNr)"
        let invoicePath = "\(project.name)/\(invoiceFolderName)"
        let writeFolderPublisher = repository.writeFolder(at: invoicePath)

        // Save json
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(data)
        let invoiceJsonPath = "\(invoicePath)/data.json"
        let writeJsonPublisher = repository.writeFile(jsonData, at: invoiceJsonPath)

        // Save pdf
        let pdfName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
        let pdfPath = "\(invoicePath)/\(pdfName)"
        let writePdfPublisher = repository.writeFile(pdfData!, at: pdfPath)

        let publisher = Publishers.Zip3(writeFolderPublisher, writeJsonPublisher, writePdfPublisher)
        .map { x in
            return Invoice(date: data.date, invoiceNr: invoiceNr, name: invoiceFolderName)
        }
        .eraseToAnyPublisher()

        return publisher
    }

    func deleteInvoice (_ invoice: Invoice, in folder: Project) -> AnyPublisher<Bool, Never> {

        let invoicePath = "\(folder.name)/\(invoice.name)"
        return repository.removeItem(at: invoicePath)
    }

    static var emptyInvoiceData: InvoiceData {
        return InvoiceData(invoice_series: "",
                           invoice_nr: 1,
                           invoice_date: Date().yyyyMMdd,
                           invoiced_period: Date().yyyyMMdd,
                           client: CompanyData(name: "",
                                               orc: "",
                                               cui: "",
                                               address: "",
                                               county: "",
                                               bank_account: "",
                                               bank_name: ""),
                           contractor: CompanyData(name: "",
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
