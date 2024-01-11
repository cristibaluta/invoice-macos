//
//  InvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine

class InvoiceInteractor {

    private let project: Project
    private let invoicesInteractor: InvoicesInteractor

    init (project: Project, invoicesInteractor: InvoicesInteractor) {
        print("init InvoiceInteractor")
        self.project = project
        self.invoicesInteractor = invoicesInteractor
    }

    func calculate (data: InvoiceData) -> AnyPublisher<String, Never> {

        return invoicesInteractor.readInvoiceTemplates(in: project)
            .map { templates in
                /// 0 = page template
                /// 1 = row template

                var template = data.toHtmlUsingTemplate(templates.0)
                let templateRow = templates.1

                /// Add rows
                var i = 1
                var rows = ""
                for product in data.products {
                    var row = templateRow.replacingOccurrences(of: "::nr::", with: "\(i)")
                    row = row.replacingOccurrences(of: "::product::",
                                                   with: product.product_name)
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
                                                   with: "\(product.amount.stringValue_grouped2)")

                    rows += row
                    i += 1
                }
                template = template.replacingOccurrences(of: "::rows::", with: rows)
    //            print(template)
                return template
            }
            .eraseToAnyPublisher()
    }

    func save (data: InvoiceData, pdfData: Data?) -> AnyPublisher<Invoice, Never> {
        return invoicesInteractor.saveInvoice(data: data, pdfData: pdfData, in: project)
    }

}
