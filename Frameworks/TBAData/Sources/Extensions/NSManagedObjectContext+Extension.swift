import Foundation
import CoreData
import Crashlytics

extension NSManagedObjectContext {

    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            print(error)
            Crashlytics.sharedInstance().recordError(error)
            rollback()
            return false
        }
    }

    public func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }

    public func performChanges(_ block: @escaping () -> Void) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }

    public func performChangesAndWait(_ block: @escaping () -> Void, saved: (() -> ())? = nil) {
        performAndWait {
            block()
            if self.saveOrRollback() {
                saved?()
            }
        }
    }

    public func deleteAllObjects() {
        for entity in persistentStoreCoordinator?.managedObjectModel.entities ?? [] {
            deleteAllObjectsForEntity(entity: entity)
        }
    }

    public func deleteAllObjectsForEntity(entity: NSEntityDescription) {
        let fetchRequest = NSFetchRequest<NSManagedObject>()
        fetchRequest.entity = entity

        let objects = try! fetch(fetchRequest)
        deleteObjects(objects)
    }

    private func deleteObjects(_ objects: [NSManagedObject]) {
        for object in objects {
            delete(object)
        }
    }

}
