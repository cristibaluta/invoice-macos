//
//  LocalRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 20.07.2022.
//

import Foundation
import Combine
import RCLog

enum LocalRepositoryType: String {
    case main = "mainBaseUrlBookmarkKey"
    case backup = "backupBaseUrlBookmarkKey"
}

class LocalRepository {

    fileprivate let key: String

    var baseUrl: URL? {
        get {
            return getBaseUrlBookmark()
        }
        set {
            saveBaseUrl(newValue)
        }
    }

    private func execute (_ block: (URL) -> Void) {
        if let baseUrl {
            let _ = baseUrl.startAccessingSecurityScopedResource()
            block(baseUrl)
            baseUrl.stopAccessingSecurityScopedResource()
        }
    }

    init(_ type: LocalRepositoryType) {
        self.key = type.rawValue
        RCLog("init LocalRepository for key: \(key) path: \(String(describing: baseUrl))")
    }
}

extension LocalRepository: Repository {

    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never> {

        guard let baseUrl else {
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
        
        guard let baseUrl else {
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

        guard let baseUrl else {
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
    fileprivate func getBaseUrlBookmark() -> URL? {
        if let bookmark = UserDefaults.standard.object(forKey: key) as? NSData as Data? {
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

    fileprivate func saveBaseUrl (_ url: URL?) {
        guard let bookmark = try? url?.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil) else {
            return
        }
        UserDefaults.standard.set(bookmark, forKey: key)
        UserDefaults.standard.synchronize()
    }

    fileprivate func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}
