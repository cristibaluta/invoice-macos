//
//  ProjectsInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 09.04.2022.
//

import Foundation
import Combine
import SwiftUI

class ProjectsInteractor {

    private let repository: Repository
//    var cancellables = Set<AnyCancellable>()
//    var cancellable: AnyCancellable?

    init (repository: Repository) {
        self.repository = repository
    }

    func refreshProjectsList() -> AnyPublisher<[Project], Never> {

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
                return Project(name: file)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func createProject (_ name: String, completion: (Project?) -> Void) {

        repository.execute { baseUrl in
            // Generate folder if none exists
            let project = Project(name: name)
            let projectUrl = baseUrl.appendingPathComponent(name)
            _ = repository.writeFolder(at: projectUrl)

            // Create templates folder
            let templateUrl = projectUrl.appendingPathComponent("templates")
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
            completion(project)
        }
    }

    func deleteProject (_ name: String, completion: (Bool) -> Void) {

        repository.execute { baseUrl in
            let projectUrl = baseUrl.appendingPathComponent(name)
            _ = repository.removeItem(at: projectUrl)
            completion(true)
        }
    }
}
