import CoreData

extension NSManagedObjectContext {

    public func insertObject<T: Managed>() throws -> T {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else { throw TBADataError.wrongObjectType }
        return obj
    }

    /*
    public func saveOrRollback(errorRecorder: ErrorRecorder) rethrows {
        do {
            try save()
        } catch {
            rollback()
        }
    }

    public func performSaveOrRollback(errorRecorder: ErrorRecorder) {
        perform {
            _ = self.saveOrRollback(errorRecorder: errorRecorder)
        }
    }

    public func performChanges(_ block: @escaping () -> Void, errorRecorder: ErrorRecorder) {
        perform {
            block()
            _ = self.saveOrRollback(errorRecorder: errorRecorder)
        }
    }

    public func performChangesAndWait(_ block: @escaping () -> Void, saved: (() -> ())? = nil, errorRecorder: ErrorRecorder) {
        performAndWait {
            block()
            if self.saveOrRollback(errorRecorder: errorRecorder) {
                saved?()
            }
        }
    }

    public func performAndWait<T>(_ block: () -> T) -> T {
        var result: T!
        performAndWait {
            result = block()
        }
        return result
    }

    public func performAndWait<T>(_ block: () -> T?) -> T? {
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
    */

}
