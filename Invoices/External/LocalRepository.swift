//
//  LocalRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 20.07.2022.
//

import Foundation

class LocalRepository: SandboxRepository {

    override func execute (_ block: (URL) -> Void) {

        if let baseUrl = BookmarkUrl().getBaseUrlBookmark() {
            let _ = baseUrl.startAccessingSecurityScopedResource()
            block(baseUrl)
            baseUrl.stopAccessingSecurityScopedResource()
        }
    }
}


class BookmarkUrl {

    let bookmarkKey = "baseUrlBookmarkKey"

    /// Returns a temporary url
    func getBaseUrlBookmark() -> URL? {
        if let bookmark = UserDefaults.standard.object(forKey: bookmarkKey) as? NSData as Data? {
            var stale = false
            if let url = try? URL(resolvingBookmarkData: bookmark, options: URL.BookmarkResolutionOptions.withSecurityScope,
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
