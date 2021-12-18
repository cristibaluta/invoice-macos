//
//  FileAccess.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.09.2021.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

class AppFilesManager {
    
    static func executeInSelectedDir (_ block: (URL) -> Void) {
//        IcloudFilesManager.default.executeInSelectedDir(block)
        block(getDocumentsDirectory())
    }
}
//        if let url = History().getLastProjectDir() {
//            let _ = url.startAccessingSecurityScopedResource()
//            block(url)
//            url.stopAccessingSecurityScopedResource()
//        }
