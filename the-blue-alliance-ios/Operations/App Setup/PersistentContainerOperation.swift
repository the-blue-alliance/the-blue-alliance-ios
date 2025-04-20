import CoreData
import Foundation

struct PersistentContainerOperation {

    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func execute() async throws -> NSPersistentStoreDescription {
        return try await withCheckedThrowingContinuation { continuation in
            persistentContainer.loadPersistentStores(completionHandler: { (desc, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                self.persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)

                continuation.resume(returning: desc)
            })
        }
    }
}
