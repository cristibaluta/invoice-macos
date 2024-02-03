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

    init (repository: Repository) {
        self.repository = repository
    }

    func loadProjectsList() -> AnyPublisher<[Project], Never> {

        return repository
            .readFolderContent(at: "")
            .compactMap { file in
                // Ignore hidden files and json files
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

    func createProject (_ name: String) -> AnyPublisher<Project, Never> {

        // Create folder if none exists
        let createFolder = repository
            .writeFolder(at: name)

        // Create templates folder
        let templatesPath = "\(name)/templates"
        let createTemplatesFolder = repository
            .writeFolder(at: templatesPath)

        // Copy templates from bundle to templates folder
        let templates = ["template_invoice",
                         "template_invoice_row",
                         "template_report",
                         "template_report_project",
                         "template_report_row"]
        let publishers: [AnyPublisher<Bool, Never>] = templates.compactMap { template in
            guard let bundleUrl = Bundle.main.url(forResource: template, withExtension: ".html") else {
                return nil
            }
            guard let templateData = try? Data(contentsOf: bundleUrl) else {
                return nil
            }
            let templatePath = "\(templatesPath)/\(template).html"
            return self.repository.writeFile(templateData, at: templatePath)
        }
        let copyTemplates = Publishers.MergeMany(publishers)

        return Publishers.Zip3(createFolder, createTemplatesFolder, copyTemplates)
            .map { _ in
                return Project(name: name)
            }
            .eraseToAnyPublisher()
    }

    func deleteProject (_ name: String) -> AnyPublisher<Bool, Never> {

        return repository
            .removeItem(at: name)
            .eraseToAnyPublisher()
    }
}
