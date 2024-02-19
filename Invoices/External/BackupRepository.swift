//
//  BackupRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 18.02.2024.
//

import Foundation
import Combine
import RCLog

class BackupRepository {

    private let mainRepository: Repository
    private let backupRepository: Repository

    var baseUrl: URL? {
        return mainRepository.baseUrl
    }

    init (mainRepository: Repository, backupRepository: Repository) {
        self.mainRepository = mainRepository
        self.backupRepository = backupRepository
    }
}

extension BackupRepository: Repository {

    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never> {
        return mainRepository.readFolderContent(at: path)
    }

    func readFile (at path: String) -> AnyPublisher<Data, Never> {
        return mainRepository.readFile(at: path)
    }

    func readFiles (at paths: [String]) -> Publishers.Sequence<[Data], Never> {
        return mainRepository.readFiles(at: paths)
    }

    func writeFolder (at path: String) -> AnyPublisher<Bool, Never> {

        return mainRepository.writeFolder(at: path)
            .flatMap { success in
                self.backupRepository.writeFolder(at: path)
            }
            .eraseToAnyPublisher()
    }

    func writeFile (_ contents: Data, at path: String) -> AnyPublisher<Bool, Never> {

        RCLog(path)
        return mainRepository.writeFile(contents, at: path)
            .flatMap { success in
                return self.backupRepository.writeFile(contents, at: path)
            }
            .eraseToAnyPublisher()
    }

    func removeItem (at path: String) -> AnyPublisher<Bool, Never> {

        return mainRepository.removeItem(at: path)
            .flatMap { success in
                self.backupRepository.removeItem(at: path)
            }
            .eraseToAnyPublisher()
    }
}
