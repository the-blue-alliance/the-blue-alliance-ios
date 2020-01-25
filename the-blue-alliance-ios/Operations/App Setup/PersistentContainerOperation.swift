import CoreData
import Foundation
import Search
import TBAOperation

class PersistentContainerOperation: TBAOperation {

    let indexDelegate: TBACoreDataCoreSpotlightDelegate
    let persistentContainer: NSPersistentContainer

    init(indexDelegate: TBACoreDataCoreSpotlightDelegate, persistentContainer: NSPersistentContainer) {
        self.indexDelegate = indexDelegate
        self.persistentContainer = persistentContainer

        super.init()
    }

    override func execute() {
        // Setup our Core Data + Spotlight export
        persistentContainer.persistentStoreDescriptions.forEach {
            $0.setOption(indexDelegate, forKey: NSCoreDataCoreSpotlightExporter)
        }
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
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
            self.completionError = error
            self.finish()
        })
    }

}
