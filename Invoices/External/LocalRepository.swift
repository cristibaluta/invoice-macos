//
//  LocalRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 20.07.2022.
//

import Foundation
import Combine
import RCLog

class LocalRepository {

    static fileprivate let bookmarkKey = "baseUrlBookmarkKey"

    var baseUrl: URL? {
        return LocalRepository.getBaseUrlBookmark()
    }

    private func execute (_ block: (URL) -> Void) {
        if let baseUrl = LocalRepository.getBaseUrlBookmark() {
            let _ = baseUrl.startAccessingSecurityScopedResource()
            block(baseUrl)
            baseUrl.stopAccessingSecurityScopedResource()
        }
    }
}

extension LocalRepository: Repository {

    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never> {

        guard let baseUrl = LocalRepository.getBaseUrlBookmark() else {
            return Publishers.Sequence(sequence: [])
        }
        defer {
            baseUrl.stopAccessingSecurityScopedResource()
        }
        _ = baseUrl.startAccessingSecurityScopedResource()

        do {
            let url = baseUrl.appendingPathComponent(path)
            let folders = try FileManager.default.contentsOfDirectory(atPath: url.path).sorted(by: {$0 > $1})
            return Publishers.Sequence(sequence: folders)
        }
        catch {
            print(error)
            return Publishers.Sequence(sequence: [])
        }
    }

    func readFile (at path: String) -> AnyPublisher<Data, Never> {

        return Future<Data, Never> { promise in
            self.execute { baseUrl in
                do {
                    let url = baseUrl.appendingPathComponent(path)
                    let data = try Data(contentsOf: url)
                    promise(.success(data))
                } catch {
                    print(error)
                    promise(.success(Data()))
                }
            }
        }
        .flatMap { data in
            CurrentValueSubject<Data, Never>(data)
        }
        .eraseToAnyPublisher()
    }
    
    func readFiles (at paths: [String]) -> Publishers.Sequence<[Data], Never> {
        
        guard let baseUrl = LocalRepository.getBaseUrlBookmark() else {
            return Publishers.Sequence(sequence: [])
        }
        defer {
            baseUrl.stopAccessingSecurityScopedResource()
        }
        _ = baseUrl.startAccessingSecurityScopedResource()

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
        
        return Future<Bool, Never> { promise in
            self.execute { baseUrl in
                do {
                    let url = baseUrl.appendingPathComponent(path)
                    try FileManager.default.createDirectory(at: url,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                    promise(.success(true))
                } catch {
                    print(error)
                    promise(.success(false))
                }
            }
        }
        .flatMap { success in
            CurrentValueSubject<Bool, Never>(success)
        }
        .eraseToAnyPublisher()
    }

    func writeFile (_ contents: Data, at path: String) -> AnyPublisher<Bool, Never> {

        guard let baseUrl = LocalRepository.getBaseUrlBookmark() else {
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }
        _ = baseUrl.startAccessingSecurityScopedResource()

        do {
            let url = baseUrl.appendingPathComponent(path)
            RCLog(url.absoluteString.components(separatedBy: ".").last!)
            try contents.write(to: url)
            baseUrl.stopAccessingSecurityScopedResource()
            return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
        } catch {
            RCLog(error)
            baseUrl.stopAccessingSecurityScopedResource()
            return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        }


//        return Future<Bool, Never> { promise in
//            self.execute { baseUrl in
//                do {
//                    let url = baseUrl.appendingPathComponent(path)
//                    RCLog(url)
//                    try contents.write(to: url)
//                    promise(.success(true))
//                } catch {
//                    print(error)
//                    promise(.success(false))
//                }
//            }
//        }
//        .flatMap { success in
//            CurrentValueSubject<Bool, Never>(success)
//        }
//        .eraseToAnyPublisher()
    }

    func removeItem (at path: String) -> AnyPublisher<Bool, Never> {

        return Future<Bool, Never> { promise in
            self.execute { baseUrl in
                do {
                    let url = baseUrl.appendingPathComponent(path)
                    try FileManager.default.removeItem(at: url)
                    promise(.success(true))
                } catch {
                    print(error)
                    promise(.success(false))
                }
            }
        }
        .flatMap { success in
            CurrentValueSubject<Bool, Never>(success)
        }
        .eraseToAnyPublisher()
    }
}

extension LocalRepository {

    /// Returns a temporary url
    static func getBaseUrlBookmark() -> URL? {
        if let bookmark = UserDefaults.standard.object(forKey: bookmarkKey) as? NSData as Data? {
            var stale = false
            if let url = try? URL(resolvingBookmarkData: bookmark,
                                  options: URL.BookmarkResolutionOptions.withSecurityScope,
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &stale) {
                return url
            }
        }
        return nil
    }

    static func setBaseUrl (_ url: URL?) {
        guard let bookmark = try? url?.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil) else {
            return
        }
        UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
        UserDefaults.standard.synchronize()
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        UserDefaults.standard.synchronize()
    }
}
