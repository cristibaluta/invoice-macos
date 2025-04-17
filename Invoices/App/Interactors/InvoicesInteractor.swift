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

    func readInvoices (_ invoices: [Invoice], in project: Project) -> AnyPublisher<[InvoiceData], Never> {

        let paths: [String] = invoices.map({ "\(project.name)/\($0.name)/data.json" })

        return repository
            .readFiles(at: paths)
            .compactMap { data in
                let decoder = JSONDecoder()
                return try? decoder.decode(InvoiceData.self, from: data)
            }
            .collect()
//            .decode(type: [InvoiceData].self, decoder: JSONDecoder())
//            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    func deleteInvoice (_ invoice: Invoice, in folder: Project) -> AnyPublisher<Bool, Never> {

        let invoicePath = "\(folder.name)/\(invoice.name)"
        return repository
            .removeItem(at: invoicePath)
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
                           vat_percent: 0,
                           vat_amount: 0,
                           amount_total: 0,
                           amount_total_vat: 0)
    }
}
