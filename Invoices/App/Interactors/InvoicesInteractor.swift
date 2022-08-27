//
//  InvoicesInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine

class InvoicesInteractor {

    let repository: Repository

    init (repository: Repository) {
        self.repository = repository
    }

    func refreshInvoicesList (for folder: Folder) -> AnyPublisher<[Invoice], Never> {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let folderUrl = documentsDirectory.appendingPathComponent(folder.name)

        return repository
            .readFolderContent(at: folderUrl)
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

    func readInvoice (for invoice: Invoice, in folder: Folder) -> AnyPublisher<InvoiceData, Never> {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let invoiceUrl = documentsDirectory
            .appendingPathComponent(folder.name)
            .appendingPathComponent(invoice.name)
            .appendingPathComponent("data.json")
        print(invoiceUrl)
        
        return repository
            .readFile(at: invoiceUrl)
            .decode(type: InvoiceData.self, decoder: JSONDecoder())
            .replaceError(with: InvoicesInteractor.emptyInvoiceData)
            .eraseToAnyPublisher()
    }

    func readInvoiceTemplates (in folder: Folder) -> AnyPublisher<(String, String), Never> {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let folderUrl = documentsDirectory.appendingPathComponent(folder.name)
        let templatesUrl = folderUrl.appendingPathComponent("templates")

        let template_invoice = repository
            .readFile(at: templatesUrl.appendingPathComponent("template_invoice.html"))
            .map { String(decoding: $0, as: UTF8.self) }

        let template_invoice_row = repository
            .readFile(at: templatesUrl.appendingPathComponent("template_invoice_row.html"))
            .map { String(decoding: $0, as: UTF8.self) }

        let publisher = Publishers.Zip(template_invoice, template_invoice_row).eraseToAnyPublisher()

        return publisher
    }

    func saveInvoice (data: InvoiceData, pdfData: Data?, in folder: Folder, completion: @escaping (Invoice) -> Void) {

        repository.execute { baseUrl in
            // Generate folder if none exists
            let invoiceNr = "\(data.invoice_series)\(data.invoice_nr.prefixedWith0)"
            let invoiceFolderName = "\(data.date.yyyyMMdd)-\(invoiceNr)"

            let folderUrl = baseUrl.appendingPathComponent(folder.name)
            let invoiceUrl = folderUrl.appendingPathComponent(invoiceFolderName)

            do {
                // Create folder if does not exist
                let write_folder = repository.writeFolder(at: invoiceUrl)

                // Save json
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let invoiceJsonUrl = invoiceUrl.appendingPathComponent("data.json")
                let jsonData = try encoder.encode(data)

                let write_json = repository.writeFile(jsonData, at: invoiceJsonUrl)

                let _ = Publishers.Zip(write_folder, write_json)
                .sink { x in
                    completion(Invoice(date: data.date, invoiceNr: invoiceNr, name: invoiceFolderName))
                }

                // Save pdf
                let pdfName = "Invoice-\(data.invoice_series)\(data.invoice_nr.prefixedWith0)-\(data.date.yyyyMMdd).pdf"
                let pdfUrl = invoiceUrl.appendingPathComponent(pdfName)
                try pdfData?.write(to: pdfUrl)
            }
            catch {
                print(error)
            }
        }
    }

    func deleteInvoice (_ invoice: Invoice, in folder: Folder, completion: (Bool) -> Void) {

        repository.execute { baseUrl in
            let folderUrl = baseUrl.appendingPathComponent(folder.name)
            let invoiceUrl = folderUrl.appendingPathComponent(invoice.name)
            _ = repository.removeItem(at: invoiceUrl)
            completion(true)
        }
    }

    func execute (_ block: (URL) -> Void) {
        repository.execute(block)
    }

    static var emptyInvoiceData: InvoiceData {
        return InvoiceData(invoice_series: "",
                           invoice_nr: 1,
                           invoice_date: Date().yyyyMMdd,
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
