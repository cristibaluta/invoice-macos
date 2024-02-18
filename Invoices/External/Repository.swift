//
//  Repository.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine

enum RepositoryType: Int {
    case sandbox
    case icloud
    case custom

    var name: String {
        switch self {
            case .sandbox: return "App's Sandbox"
            case .icloud: return "iCloud Drive"
            case .custom: return "Custom path"
        }
    }
}

protocol Repository {
    var baseUrl: URL? { get }
    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never>
//    func readFolderContent2 (at url: URL) -> AnyPublisher<[String], Never>
    func readFile (at path: String) -> AnyPublisher<Data, Never>
    func readFiles (at paths: [String]) -> Publishers.Sequence<[Data], Never>
    func writeFolder (at path: String) -> AnyPublisher<Bool, Never>
    func writeFile (_ contents: Data, at path: String) -> AnyPublisher<Bool, Never>
    func removeItem (at path: String) -> AnyPublisher<Bool, Never>
}
