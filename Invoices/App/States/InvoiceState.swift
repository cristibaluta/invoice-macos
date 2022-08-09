//
//  InvoiceState.swift
//  Invoices
//
//  Created by Cristian Baluta on 28.07.2022.
//

import Foundation
import Combine

class InvoiceState: ObservableObject {

    private var cancellable: Cancellable?
    private let invoicesInteractor: InvoicesInteractor

    var project: Project
    var html = ""
    var data: InvoiceData


    init (project: Project,
          data: InvoiceData,
          invoicesInteractor: InvoicesInteractor) {

        print("init InvoiceState")
        self.project = project
        self.data = data
        self.invoicesInteractor = invoicesInteractor
    }

    func calculate (completion: @escaping (String) -> Void) {

        cancellable = invoicesInteractor.readInvoiceTemplates(in: project)
        .sink { templates in
            /// 0 = page template
            /// 1 = row template
            self.data.calculate()

            var template = self.data.toHtmlUsingTemplate(templates.0)
            let templateRow = templates.1

            /// Add rows
            var i = 1
            var rows = ""
            for product in self.data.products {
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
//            print(template)

            self.html = template
            completion(template)
        }
    }

    func save (pdfData: Data?, completion: @escaping (InvoiceFolder?) -> Void) {

        invoicesInteractor.saveInvoice(data: data, pdfData: pdfData, in: project) { invoiceFolder in
            completion(invoiceFolder)
        }
    }

}
