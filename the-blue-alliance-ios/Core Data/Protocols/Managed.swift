import CoreData

protocol Managed: class, NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
    var isOrphaned: Bool { get }
}

extension Managed where Self: NSManagedObject {

    static var entity: NSEntityDescription { return entity()  }

    static var entityName: String { return entity.name!  }

    static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> Void) -> Self {
        var object = findOrFetch(in: context, matching: predicate)
        if object == nil {
            object = context.insertObject()
        }
        configure(object!)
        return object!
    }

    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return object
    }

    static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return context.performAndWait {
            return try! context.fetch(request)
        }!
    }

    static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void = { _ in }) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return try! context.count(for: request)
    }

    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }

    static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void) -> Self? {
        let result = fetch(in: context) { request in
            configure(request)
            request.fetchLimit = 1
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }

    func updateToOneRelationship<J: Any, T: NSManagedObject & Managed>(relationship: String, newValue: J?, newObject: (J) -> T) {
        // Store our old value so we can reference it later
        let oldValue = value(forKeyPath: relationship) as? T

        // The ol' switcharoo
        if let newValue = newValue {
            setValue(newObject(newValue), forKeyPath: relationship)
        } else {
            setValue(nil, forKeyPath: relationship)
        }

        // Clean up orphan, if applicable
        if let oldValue = oldValue, oldValue.isOrphaned {
            managedObjectContext?.delete(oldValue)
        }
    }

    func updateToManyRelationship<T: NSManagedObject & Managed>(relationship: String, newValues new: [T]?) {
        // Store our old values so we can reference them later
        let oldSet = value(forKeyPath: relationship) as? NSSet
        let oldValues = oldSet?.allObjects as? [T]

        // The ol' switcharoo
        let newSet = Set(new ?? [])
        setValue(NSSet(set: newSet), forKeyPath: relationship)

        // Clean up orphans, if applicable
        if let oldValues = oldValues {
            let oldSet = Set(oldValues)
            oldSet.subtracting(newSet).filter({ $0.isOrphaned }).forEach({
                managedObjectContext?.delete($0)
            })
        }
    }

}
