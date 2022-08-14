import CoreData
import Foundation
import TBAKit

struct DestroyPersistentStoreOperation {

    private static let CoreDataVersionKey: String = "CoreDataVersion"
    private static let CoreDataVersion: Int = 2

    private let persistentContainer: NSPersistentContainer
    private let tbaKit: TBAKit
    private let userDefaults: UserDefaults

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults
    }

    func execute() throws {
        // See if we need to nuke our persistent store due to an upgrade
        let coreDataVersion = userDefaults.integer(forKey: DestroyPersistentStoreOperation.CoreDataVersionKey)
        if coreDataVersion < DestroyPersistentStoreOperation.CoreDataVersion {
            var success = false
            for url in FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask) {
                let coreDataURL = url.appendingPathComponent("TBA.sqlite")
                if FileManager.default.fileExists(atPath: coreDataURL.path) {
                    try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: coreDataURL, ofType: "sqlite", options: nil)
                    success = true
                }
            }
            if success {
                tbaKit.clearCacheHeaders()
                userDefaults.set(DestroyPersistentStoreOperation.CoreDataVersion, forKey: DestroyPersistentStoreOperation.CoreDataVersionKey)
                userDefaults.synchronize()
            }
        }
    }
    
}
