//
//  Repository.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine

protocol Repository {
    var baseUrl: URL { get }
    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never>
//    func readFolderContent2 (at url: URL) -> AnyPublisher<[String], Never>
    func readFile (at path: String) -> AnyPublisher<Data, Never>
    func writeFolder (at path: String) -> AnyPublisher<Bool, Never>
    func writeFile (_ contents: Data, at path: String) -> AnyPublisher<Bool, Never>
    func removeItem (at path: String) -> AnyPublisher<Bool, Never>
}
