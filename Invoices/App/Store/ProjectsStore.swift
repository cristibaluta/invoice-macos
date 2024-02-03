//
//  Environment.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.05.2022.
//

import Foundation
import Combine
import RCPreferences
import BarChart

class ProjectsStore: ObservableObject {

    @Published var projects: [Project] = []
    @Published var selectedProject: Project? {
        didSet {
            print("Selected new projects \(String(describing: selectedProject))")
            pref.set(selectedProject?.name ?? "", forKey: .lastProject)

            cancellables.removeAll()

            if let project = selectedProject {
                self.invoicesStore = InvoicesStore(repository: repository, project: project)
                self.invoicesStore!.chartPublisher
                    .sink { chartViewModel in
                        self.chartSubject.send()
                    }
                    .store(in: &cancellables)
                self.invoicesStore!.didSaveInvoicePublisher
                    .sink {
                        self.invoicesStore?.loadInvoices()
                    }
                    .store(in: &cancellables)
                self.invoicesStore?.loadInvoices()
            } else {
                self.invoicesStore = nil
            }
            projectSubject.send()
        }
    }
    @Published var invoicesStore: InvoicesStore?
    @Published var isShowingNewProjectSheet = false
    @Published var isShowingDeleteProjectAlert = false

    private let interactor: ProjectsInteractor
    private let repository: Repository
    private var pref = RCPreferences<UserPreferences>()
    private var cancellables = Set<AnyCancellable>()

    private let projectSubject = PassthroughSubject<Void, Never>()
    var projectDidChangePublisher: AnyPublisher<Void, Never> {
        projectSubject.eraseToAnyPublisher()
    }

    private let chartSubject = PassthroughSubject<Void, Never>()
    var chartDidChangePublisher: AnyPublisher<Void, Never> {
        chartSubject.eraseToAnyPublisher()
    }


    init (repository: Repository) {
        self.repository = repository
        self.interactor = ProjectsInteractor(repository: repository)
    }

    func refresh() {
        _ = interactor.loadProjectsList()
            .sink { [weak self] in
                self?.projects = $0
            }
    }

    func createProject (named name: String) {
        guard !name.isEmpty else {
            return
        }
        _ = interactor.createProject(name)
            .sink { project in
                self.refresh()
                self.dismissNewProject()
                self.selectedProject = project
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

    private func selectProject (named name: String) {
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
