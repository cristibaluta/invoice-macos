//
//  Repository.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine

protocol Repository {
    /// All repository requests must be executed in this block. The block returns the baseURL
    func execute (_ block: (URL) -> Void)
    func readFolderContent (at url: URL) -> Publishers.Sequence<[String], Never>
    func readFile (at url: URL) -> AnyPublisher<Data, Never>
    func writeFolder (at url: URL) -> AnyPublisher<Bool, Never>
    func writeFile (_ contents: Data, at url: URL) -> AnyPublisher<Bool, Never>
    func removeItem (at url: URL) -> AnyPublisher<Bool, Never>
}
