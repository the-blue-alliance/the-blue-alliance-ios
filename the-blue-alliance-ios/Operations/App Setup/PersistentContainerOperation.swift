import CoreData
import Foundation
import Search
import TBAOperation

struct PersistentContainerOperation {

    private let indexDelegate: TBACoreDataCoreSpotlightDelegate
    private let persistentContainer: NSPersistentContainer

    init(indexDelegate: TBACoreDataCoreSpotlightDelegate, persistentContainer: NSPersistentContainer) {
        self.indexDelegate = indexDelegate
        self.persistentContainer = persistentContainer
    }

    func execute() async throws -> NSPersistentStoreDescription {
        // Setup our Core Data + Spotlight export
        persistentContainer.persistentStoreDescriptions.forEach {
            $0.setOption(indexDelegate, forKey: NSCoreDataCoreSpotlightExporter)
        }
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
