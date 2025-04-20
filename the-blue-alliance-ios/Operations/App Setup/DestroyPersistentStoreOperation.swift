import CoreData
import Foundation
import TBAKit

struct DestroyPersistentStoreOperation {

    private static let CoreDataVersionKey: String = "CoreDataVersion"
    private static let CoreDataVersion: Int = 2

    private let persistentContainer: NSPersistentContainer
    private let userDefaults: UserDefaults

    init(persistentContainer: NSPersistentContainer, userDefaults: UserDefaults) {
        self.persistentContainer = persistentContainer
        self.userDefaults = userDefaults
    }

    func execute() async throws {
        // See if we need to nuke our persistent store due to an upgrade
        let coreDataVersion = userDefaults.integer(forKey: DestroyPersistentStoreOperation.CoreDataVersionKey)
        if coreDataVersion < DestroyPersistentStoreOperation.CoreDataVersion {
            var success = false
            for store in self.persistentContainer.persistentStoreCoordinator.persistentStores {
                guard let url = store.url else {
                    continue
                }
                let type = NSPersistentStore.StoreType(rawValue: store.type)
                try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, type: type)
                success = true
            }
            if success {
                userDefaults.set(DestroyPersistentStoreOperation.CoreDataVersion, forKey: DestroyPersistentStoreOperation.CoreDataVersionKey)
                userDefaults.synchronize()

                _ = try await PersistentContainerOperation(persistentContainer: persistentContainer).execute()
            }
        }
    }

}
