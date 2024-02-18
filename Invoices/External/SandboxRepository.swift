//
//  FileAccess.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.09.2021.
//

import Foundation
import Combine

class SandboxRepository {

    var baseUrl: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
//        print(documentsDirectory)
        return documentsDirectory
    }
}

extension SandboxRepository: Repository {

    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never> {
        guard let url = baseUrl?.appendingPathComponent(path) else {
            return Publishers.Sequence(sequence: [])
        }
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: url.path).sorted(by: {$0 > $1})
            return folders.publisher
        }
        catch {
            print(error)
            return Publishers.Sequence(sequence: [])
        }
    }

    func readFile (at path: String) -> AnyPublisher<Data, Never> {
        guard let url = baseUrl?.appendingPathComponent(path) else {
            return CurrentValueSubject<Data, Never>(Data()).eraseToAnyPublisher()
        }
        do {
            let data = try Data(contentsOf: url)
            return CurrentValueSubject<Data, Never>(data).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Data, Never>(Data()).eraseToAnyPublisher()
        }
    }

    func readFiles (at paths: [String]) -> Publishers.Sequence<[Data], Never> {
        guard let baseUrl else {
            return Publishers.Sequence(sequence: [])
        }
        var datas = [Data]()
        for path in paths {
            do {
                let url = baseUrl.appendingPathComponent(path)
                let data = try Data(contentsOf: url)
                datas.append(data)
            } catch {
                print(error)
            }
        }
        return Publishers.Sequence(sequence: datas)
    }

    func writeFolder (at path: String) -> AnyPublisher<Bool, Never> {
        guard let url = baseUrl?.appendingPathComponent(path) else {
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
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

    func writeFile (_ contents: Data, at path: String) -> AnyPublisher<Bool, Never> {
        guard let url = baseUrl?.appendingPathComponent(path) else {
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
        do {
            try contents.write(to: url)
            return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
    }

    func removeItem (at path: String) -> AnyPublisher<Bool, Never> {
        guard let url = baseUrl?.appendingPathComponent(path) else {
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
        do {
            try FileManager.default.removeItem(at: url)
            return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
        } catch {
            print(error)
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
    }

}
