//
//  Exporter.swift
//  Invoices
//
//  Created by Cristian Baluta on 22.07.2022.
//

import Foundation
import AppKit

class Exporter {

    func export (fileName: String, data: InvoiceData, printData: Data?, html: String, isPdf: Bool) {

        let panel = NSSavePanel()
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = fileName
        panel.begin { result in
            if result == NSApplication.ModalResponse.OK {
                if let url = panel.url {
                    do {
                        if isPdf {
                            try printData?.write(to: url)
                        } else {
                            try html.write(to: url, atomically: true, encoding: .utf8)
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
    }

}
