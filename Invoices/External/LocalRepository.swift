//
//  LocalRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 20.07.2022.
//

import Foundation
import Combine

class LocalRepository {

    var baseUrl: URL? {
        return BookmarkUrl().getBaseUrlBookmark()!
    }
    private func execute (_ block: (URL) -> Void) {
        if let baseUrl = BookmarkUrl().getBaseUrlBookmark() {
            let _ = baseUrl.startAccessingSecurityScopedResource()
            block(baseUrl)
            baseUrl.stopAccessingSecurityScopedResource()
        }
    }
}

extension LocalRepository: Repository {

    func readFolderContent (at path: String) -> Publishers.Sequence<[String], Never> {
        let p = PassthroughSubject<[String], Never>()
        execute { baseUrl in
            do {
                let url = baseUrl.appendingPathComponent(path)
                let folders = try FileManager.default.contentsOfDirectory(atPath: url.path).sorted(by: {$0 > $1})
                p.send(folders)
            }
            catch {
                print(error)
                p.send([])
            }
            p.send(completion: .finished)
        }
//        return p.eraseToAnyPublisher()
        return Publishers.Sequence(sequence: [])
    }

    func readFile (at path: String) -> AnyPublisher<Data, Never> {
        return CurrentValueSubject<Data, Never>(Data()).eraseToAnyPublisher()
    }
    func readFiles (at paths: [String]) -> Publishers.Sequence<[Data], Never> {
        return Publishers.Sequence(sequence: [])
    }
    func writeFolder (at path: String) -> AnyPublisher<Bool, Never> {
        return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    }
    func writeFile (_ contents: Data, at path: String) -> AnyPublisher<Bool, Never> {
        return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    }
    func removeItem (at path: String) -> AnyPublisher<Bool, Never> {
        return CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    }
}


class BookmarkUrl {

    let bookmarkKey = "baseUrlBookmarkKey"

    /// Returns a temporary url
    func getBaseUrlBookmark() -> URL? {
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

    func setBaseUrl (_ url: URL?) {
        guard let bookmark = try? url?.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil) else {
            return
        }
        UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
        UserDefaults.standard.synchronize()
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        UserDefaults.standard.synchronize()
    }
}
