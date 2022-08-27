//
//  FileAccess.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.09.2021.
//

import Foundation
import Combine

class SandboxRepository {

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print(documentsDirectory)
        return documentsDirectory
    }


    var readFolderContentPublisher: AnyPublisher<[String], Never> {
        readFolderContentSubject.eraseToAnyPublisher()
    }
    private let readFolderContentSubject = PassthroughSubject<[String], Never>()

}

extension SandboxRepository: Repository {
    @objc
    func execute (_ block: (URL) -> Void) {
        block(getDocumentsDirectory())
    }

    func readFolderContent2 (at url: URL) -> AnyPublisher<[String], Never> {
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: url.path).sorted(by: {$0 > $1})
            readFolderContentSubject.send(folders)
        }
        catch {
            print(error)
        }
        return readFolderContentPublisher
    }

    func readFolderContent (at url: URL) -> Publishers.Sequence<[String], Never> {
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: url.path).sorted(by: {$0 > $1})
            return folders.publisher
        }
        catch {
            print(error)
            return Publishers.Sequence(sequence: [])
        }
    }

    func readFile (at url: URL) -> AnyPublisher<Data, Never> {
        do {
            let data = try Data(contentsOf: url)
            return CurrentValueSubject<Data, Never>(data).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Data, Never>(Data()).eraseToAnyPublisher()
        }
    }

    func writeFolder (at url: URL) -> AnyPublisher<Bool, Never> {
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
    }

    func writeFile (_ contents: Data, at url: URL) -> AnyPublisher<Bool, Never> {
        do {
            try contents.write(to: url)
            return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
    }

    func removeItem (at url: URL) -> AnyPublisher<Bool, Never> {
        do {
            try FileManager.default.removeItem(at: url)
            return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
    }

}
