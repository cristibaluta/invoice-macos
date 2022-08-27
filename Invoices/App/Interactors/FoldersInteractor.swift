//
//  ProjectsInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine
import SwiftUI

class FoldersInteractor {

    private let repository: Repository
//    var cancellables = Set<AnyCancellable>()
//    var cancellable: AnyCancellable?

    init (repository: Repository) {
        self.repository = repository
    }

    func refreshFoldersList() -> AnyPublisher<[Folder], Never> {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        return repository
            .readFolderContent(at: documentsDirectory)
            .compactMap { file in
                if file.hasPrefix(".") {
                    return nil
                }
                if file.hasSuffix(".json") {
                    return nil
                }
                return Folder(name: file)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func createFolder (_ name: String, completion: (Folder?) -> Void) {

        repository.execute { baseUrl in
            // Generate folder if none exists
            let folder = Folder(name: name)
            let folderUrl = baseUrl.appendingPathComponent(name)
            _ = repository.writeFolder(at: folderUrl)

            // Create templates folder
            let templateUrl = folderUrl.appendingPathComponent("templates")
            _ = repository.writeFolder(at: templateUrl)

            // Copy templates from bundle
            let templates = ["template_invoice",
                             "template_invoice_row",
                             "template_report",
                             "template_report_project",
                             "template_report_row"]
            for template in templates {
                guard let bundleUrl = Bundle.main.url(forResource: template, withExtension: ".html") else {
                    continue
                }
                guard let templateData = try? Data(contentsOf: bundleUrl) else {
                    continue
                }
                let destUrl = templateUrl.appendingPathComponent("\(template).html")

                _ = repository.writeFile(templateData, at: destUrl)
            }
            completion(folder)
        }
    }

    func deleteFolder (_ name: String, completion: (Bool) -> Void) {

        repository.execute { baseUrl in
            let folderUrl = baseUrl.appendingPathComponent(name)
            _ = repository.removeItem(at: folderUrl)
            completion(true)
        }
    }
}
