//
//  Environment.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.05.2022.
//

import Combine
import RCPreferences

class ProjectsState: ObservableObject {

    @Published var projects: [Project] = []
    @Published var selectedProject: Project? {
        didSet {
            print("selected new project \(String(describing: selectedProject))")
            pref.set(selectedProject?.name ?? "", forKey: .lastProject)
        }
    }
    @Published var isShowingNewProjectSheet = false
    @Published var isShowingDeleteProjectAlert = false

    let interactor: ProjectsInteractor
    private var pref = RCPreferences<UserPreferences>()


    init (interactor: ProjectsInteractor) {
        self.interactor = interactor
    }

    func refresh() {
        _ = interactor.refreshProjectsList()
        .print("ProjectsState")
        .sink { [weak self] in
            self?.projects = $0
        }
    }

    func createProject (named name: String, completion: (Project?) -> Void) {
        guard !name.isEmpty else {
            completion(nil)
            return
        }
        interactor.createProject(name) { project in
            self.refresh()
            self.dismissNewProject()
            completion(project)
        }
    }

    func deleteProject (at index: Int) {
        guard index < projects.count else {
            return
        }
        let proj = projects[index]
        interactor.deleteProject(proj.name) { success in
            self.refresh()
        }
    }

    func selectProject (named name: String) {
        for proj in projects {
            if proj.name == name {
                selectedProject = proj
                break
            }
        }
    }

    func dismissNewProject() {
        self.isShowingNewProjectSheet = false
    }

    func dismissDeleteProject() {
        self.isShowingDeleteProjectAlert = false
    }
}
