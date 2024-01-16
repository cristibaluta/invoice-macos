//
//  IcloudFilesManager.swift
//  Invoices
//
//  Created by Cristian Baluta on 11.12.2021.
//

import Foundation
import Combine

class IcloudDriveRepository {

    var baseUrl: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    var publisher: AnyPublisher<String, Never> {
        subject.eraseToAnyPublisher()
    }
    private let subject = PassthroughSubject<String, Never>()

    private var iCloudContainer: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)
    }
    
    init() {
        metadataQuery.start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func execute (_ block: (URL) -> Void) {
        if let containerUrl = iCloudContainer?.appendingPathComponent("Documents") {
            if !FileManager.default.fileExists(atPath: containerUrl.path, isDirectory: nil) {
                do {
//                    try FileManager.default.removeItem(at: containerUrl)
                    try FileManager.default.createDirectory(at: containerUrl,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            
//            let fileUrl = containerUrl.appendingPathComponent("hello.txt")
//            do {
//                try FileManager.default.removeItem(at: fileUrl)
////                try "Hello iCloud!".write(to: fileUrl, atomically: true, encoding: .utf8)
////                print(try String(contentsOfFile: fileUrl.path))
//            }
//            catch {
//                print(error.localizedDescription)
//            }
            block(containerUrl)
        }
    }

    func getFilePath (container: URL, fileName: String) -> String {
        let filePath = container.appendingPathComponent(fileName).path
        return filePath
    }

    lazy var metadataQuery: NSMetadataQuery = {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K CONTAINS %@", NSMetadataItemFSNameKey, "List")

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didFinishGathering),
                                               name: NSNotification.Name.NSMetadataQueryDidUpdate,
                                               object: query)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didFinishGathering),
                                               name: NSNotification.Name.NSMetadataQueryDidFinishGathering,
                                               object: query)
        return query
    }()

    private func isMetadataItemDownloaded (item : NSMetadataItem) -> Bool {
        if item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String == NSMetadataUbiquitousItemDownloadingStatusCurrent {
            return true
        } else {
            return false
        }
    }
}

extension IcloudDriveRepository: Repository {

    func readFolderContent (at url: URL) -> Publishers.Sequence<[String], Never> {
        return publisher
            .eraseToAnyPublisher()
    }

    func writeFolder (at url: URL) -> AnyPublisher<Bool, Never> {
        return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
    }

    func writeFile (_ contents: Data, at url: URL) -> AnyPublisher<Bool, Never> {
        return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
    }

    func removeItem (at url: URL) -> AnyPublisher<Bool, Never>  {
        return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
    }
}

extension IcloudDriveRepository {
    
    @objc func didFinishGathering (notification: Notification?) {
        let query = notification?.object as? NSMetadataQuery

        query?.enumerateResults { (item: Any, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            let metadataItem = item as! NSMetadataItem

            if isMetadataItemDownloaded(item: metadataItem) == false {
                let url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as! URL
                try? FileManager.default.startDownloadingUbiquitousItem(at: url)
            }
        }

        guard let queryresultsCount = query?.resultCount else { return }
        for index in 0..<queryresultsCount {
            let item = query?.result(at: index) as? NSMetadataItem
            let itemName = item?.value(forAttribute: NSMetadataItemFSNameKey) as! String

            let container = self.iCloudContainer
            let filePath = self.getFilePath(container: container!, fileName: "TaskList")
            let addressPath = self.getFilePath(container: container!, fileName: "CategoryList")

//            if itemName == "TaskList" {
//                if let jsonData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data {
//                    if let person = try? JSONDecoder().decode(Person.self, from: jsonData) {
//                        nameLabel.text = person.name
//                        weightLabel.text = String(person.weight)
//                    } else {
//                        nameLabel.text = "NOT decoded"
//                        weightLabel.text = "NOT decoded"
//                    }
//                } else {
//                    nameLabel.text = "NOT unarchived"
//                    weightLabel.text = "NOT unarchived"
//                }
//            }
        }
    }

//    @IBAction func saveButtonPressed(_ sender: UIButton) {
//        let container = filesCoordinator.iCloudContainer
//        let personPath = filesCoordinator.getFilePath(container: container!, fileName: "TaskList")
//        let addressPath = filesCoordinator.getFilePath(container: container!, fileName: "CategoryList")
//
//        let person = Person(name: nameTextField.text!, weight: Double(weightTextField.text!)!)
//        let jsonPersonData = try? JSONEncoder().encode(person)
//        NSKeyedArchiver.archiveRootObject(jsonPersonData!, toFile: personPath)
//
//        let address = Address(street: streetTextField.text!, house: Int(houseTextField.text!)!)
//        let jsonAddressData = try? JSONEncoder().encode(address)
//        NSKeyedArchiver.archiveRootObject(jsonAddressData!, toFile: addressPath)
//    }
}
