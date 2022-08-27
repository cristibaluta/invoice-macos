//
//  Environment.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.05.2022.
//

import Combine
import RCPreferences

class FoldersState: ObservableObject {

    @Published var folders: [Folder] = []
    @Published var selectedFolder: Folder? {
        didSet {
            print("selected new folder \(String(describing: selectedFolder))")
            pref.set(selectedFolder?.name ?? "", forKey: .lastProject)
        }
    }
    @Published var isShowingNewFolderSheet = false
    @Published var isShowingDeleteFolderAlert = false

    let interactor: FoldersInteractor
    private var pref = RCPreferences<UserPreferences>()


    init (interactor: FoldersInteractor) {
        self.interactor = interactor
    }

    func refresh() {
        _ = interactor.refreshFoldersList()
        .print("FoldersState")
        .sink { [weak self] in
            self?.folders = $0
        }
    }

    func createFolder (named name: String, completion: (Folder?) -> Void) {
        guard !name.isEmpty else {
            completion(nil)
            return
        }
        interactor.createFolder(name) { folder in
            self.refresh()
            self.dismissNewFolder()
            completion(folder)
        }
    }

    func deleteFolder (at index: Int) {
        guard index < folders.count else {
            return
        }
        let f = folders[index]
        interactor.deleteFolder(f.name) { success in
            self.refresh()
        }
    }

    func selectFolder (named name: String) {
        for f in folders {
            if f.name == name {
                selectedFolder = f
                break
            }
        }
    }

    func dismissNewFolder() {
        self.isShowingNewFolderSheet = false
    }

    func dismissDeleteFolder() {
        self.isShowingDeleteFolderAlert = false
    }
}
