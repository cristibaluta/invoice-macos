//
//  ProjectsManager.swift
//  Invoices
//
//  Created by Cristian Baluta on 30.11.2021.
//

import Foundation

class ProjectsManager {
    
    static let shared = ProjectsManager()
    
    func getProjects (completion: ([Project]) -> Void) {
        
        AppFilesManager.executeInSelectedDir { url in
            do {
                let folders = try FileManager.default.contentsOfDirectory(atPath: url.path)
                print("Projects: \(folders)")
                let projects: [Project] = folders.compactMap({
                    if $0.hasPrefix(".") {
                        return nil
                    }
                    return Project(name: $0)
                })
                completion(projects)
            }
            catch {
                completion([])
            }
        }
    }
    
    func createProject (_ name: String, completion: (Project?) -> Void) {
        AppFilesManager.executeInSelectedDir { url in
            do {
                // Generate folder if none exists
                let project = Project(name: name)
                let projectUrl = url.appendingPathComponent(name)
                try FileManager.default.createDirectory(at: projectUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                // Create templates folder
                let templateUrl = projectUrl.appendingPathComponent("templates")
                try FileManager.default.createDirectory(at: templateUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                // Copy templates from bundle
                let templates = ["template_invoice",
                                 "template_invoice_row",
                                 "template_report",
                                 "template_report_project",
                                 "template_report_row"]
                for template in templates {
                    let bundlePath = Bundle.main.path(forResource: template, ofType: ".html")
                    let destPath = templateUrl.appendingPathComponent("\(template).html").path
                    if !FileManager.default.fileExists(atPath: destPath) {
                        try FileManager.default.copyItem(atPath: bundlePath!, toPath: destPath)
                    }
                }
                completion(project)
            } catch {
                completion(nil)
            }
        }
    }
}
