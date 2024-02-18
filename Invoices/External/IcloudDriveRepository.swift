//
//  IcloudDriveRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 11.12.2021.
//

import Foundation

class IcloudDriveRepository: SandboxRepository {

    override var baseUrl: URL? {
        // Only the Documents directory is displayed in Finder
        return FileManager.default
            .url(forUbiquityContainerIdentifier: "iCloud.ro.imagin.Invoices")?
            .appendingPathComponent("Documents")
    }
    
}
