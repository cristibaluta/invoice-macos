//
//  FileAccess.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.09.2021.
//

import Foundation

class SandboxManager {
    
    static func executeInSelectedDir (_ block: (URL) -> Void) {
        if let url = History().getLastProjectDir() {
            let _ = url.startAccessingSecurityScopedResource()
            block(url)
            url.stopAccessingSecurityScopedResource()
        }
    }
}
