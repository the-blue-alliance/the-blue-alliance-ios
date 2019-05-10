import Foundation
import CoreData
import Crashlytics

extension NSManagedObject {

    /** Syncronous, thread-safe method to get a typed value from a NSManagedObject. **/
    func getValue<T, J>(_ keyPath: KeyPath<T, J>) -> J {
        guard let context = managedObjectContext else {
            fatalError("No managedObjectContext for object.")
        }
        return context.getKeyPathAndWait(obj: self, keyPath: keyPath)!
    }

}

extension NSManagedObjectContext {

    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    func saveOrRollback() -> Bool {
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

    func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }

    func performChanges(_ block: @escaping () -> Void) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }

    func performChangesAndWait(_ block: @escaping () -> Void, saved: (() -> ())? = nil) {
        performAndWait {
            block()
            if self.saveOrRollback() {
                saved?()
            }
        }
    }

    func performAndWait<T>(_ block: () -> T?) -> T? {
        var result: T? = nil
        performAndWait {
            result = block()
        }
        return result
    }

    fileprivate func getKeyPathAndWait<T, J>(obj: NSManagedObject, keyPath: KeyPath<T, J>) -> J? {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Unable to get key path string for \(keyPath)")
        }
        return performAndWait {
            return obj.value(forKeyPath: keyPathString) as? J
        }
    }

    fileprivate func setKeyPathAndWait<T, J>(obj: NSManagedObject, value: J, keyPath: KeyPath<T, J>) {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Unable to get key path string for \(keyPath)")
        }
        performAndWait {
            obj.setValue(value, forKeyPath: keyPathString)
        }
    }

    fileprivate func setNilKeyPathAndWait<T, J>(obj: NSManagedObject, keyPath: KeyPath<T, J>) {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Unable to get key path string for \(keyPath)")
        }
        performAndWait {
            obj.setNilValueForKey(keyPathString)
        }
    }

    func deleteAllObjects() {
        for entity in persistentStoreCoordinator?.managedObjectModel.entities ?? [] {
            deleteAllObjectsForEntity(entity: entity)
        }
    }

    func deleteAllObjectsForEntity(entity: NSEntityDescription) {
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
