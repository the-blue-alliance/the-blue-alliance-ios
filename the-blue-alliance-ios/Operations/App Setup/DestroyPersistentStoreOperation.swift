import CoreData
import Foundation
import TBAKit
import TBAOperation

class DestroyPersistentStoreOperation: TBAOperation {

    private static let CoreDataVersionKey: String = "CoreDataVersion"
    private static let CoreDataVersion: Int = 2

    var persistentContainer: NSPersistentContainer
    var tbaKit: TBAKit
    var userDefaults: UserDefaults

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        super.init()
    }

    override func execute() {
        // See if we need to nuke our persistent store due to an upgrade
        let coreDataVersion = userDefaults.integer(forKey: DestroyPersistentStoreOperation.CoreDataVersionKey)
        if coreDataVersion < DestroyPersistentStoreOperation.CoreDataVersion {
            var success = false
            for url in FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask) {
                let coreDataURL = url.appendingPathComponent("TBA.sqlite")
                if FileManager.default.fileExists(atPath: coreDataURL.path) {
                    do {
                        try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: coreDataURL, ofType: "sqlite", options: nil)
                        success = true
                    } catch {
                        completionError = error
                    }
                }
            }
            if success {
                tbaKit.clearCacheHeaders()
                userDefaults.set(DestroyPersistentStoreOperation.CoreDataVersion, forKey: DestroyPersistentStoreOperation.CoreDataVersionKey)
                userDefaults.synchronize()
            }
        }
        finish()
    }
    
}
