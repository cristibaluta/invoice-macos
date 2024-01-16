//
//  InvoiceEditorProtocol.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.01.2024.
//

import Foundation
import Combine

enum EditorType: Int {
    case invoice
    case report
}

protocol InvoiceEditorProtocol: ObservableObject {
    /// The type of editor
    var type: EditorType { get }
    /// Invoice data after editing
    var data: InvoiceData { get set }
    /// Publisher for data change
    var invoiceDataChangePublisher: AnyPublisher<InvoiceData, Never> { get }
    /// Publisher to add a new company
    var addCompanyPublisher: AnyPublisher<Void, Never> { get }
}

extension InvoiceEditorProtocol {

}
