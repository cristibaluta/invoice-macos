//
//  Environment.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.05.2022.
//

import Combine
import RCPreferences

class ProjectsData: ObservableObject {

    @Published var projects: [Project] = []
    @Published var selectedProject: Project? {
        didSet {
            print("Selected new projects \(String(describing: selectedProject))")
            pref.set(selectedProject?.name ?? "", forKey: .lastProject)
        }
    }
    @Published var isShowingNewProjectSheet = false
    @Published var isShowingDeleteProjectAlert = false

    let interactor: ProjectsInteractor
    private var pref = RCPreferences<UserPreferences>()
//    var cancellables = Set<AnyCancellable>()
//    var cancellable: AnyCancellable?

    init (interactor: ProjectsInteractor) {
        self.interactor = interactor
    }

    func refresh() {
        _ = interactor.loadProjectsList()
        .print("FoldersState")
        .sink { [weak self] in
            self?.projects = $0
        }
    }

    func createProject (named name: String, completion: @escaping (Project?) -> Void) {
        guard !name.isEmpty else {
            completion(nil)
            return
        }
        _ = interactor.createProject(name)
            .sink { project in
                self.refresh()
                self.dismissNewProject()
                completion(project)
            }
    }

    func deleteProject (at index: Int) {
        guard index < projects.count else {
            return
        }
        let f = projects[index]
        _ = interactor.deleteProject(f.name)
            .sink { success in
                self.refresh()
            }
    }

    func selectProject (named name: String) {
        guard let project = projects.first(where: { $0.name == name }) else {
            return
        }
        selectedProject = project
    }

    func selectLastProject() {
        guard let lastProj: String = pref.get(.lastProject) else {
            return
        }
        selectProject(named: lastProj)
    }

    func dismissNewProject() {
        self.isShowingNewProjectSheet = false
    }

    func dismissDeleteProject() {
        self.isShowingDeleteProjectAlert = false
    }
}