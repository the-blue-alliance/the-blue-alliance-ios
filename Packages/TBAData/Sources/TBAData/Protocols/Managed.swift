import CoreData

public protocol Managed: NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
}

internal protocol Orphanable {
    var isOrphaned: Bool { get async }
}

extension Managed where Self: NSManagedObject {

    public static var entity: NSEntityDescription { return entity()  }

    public static var entityName: String { return entity.name!  }

    public static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate) async throws -> Self {
        if let object = try await findOrFetch(in: context, matching: predicate) {
            return object
        }
        return try context.insertObject()
    }

    public static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) async throws -> Self? {
        if let object = await materializedObject(in: context, matching: predicate) {
            return object
        }
        return try await fetch(in: context) { request in
            request.predicate = predicate
            request.fetchLimit = 1
        }.first
    }

    public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }) async throws -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try await context.perform {
            try context.fetch(request)
        }
    }

    static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void = { _ in }) async -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return await context.perform {
            try! context.count(for: request)
        }
    }

    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) async -> Self? {
        return await context.perform {
            for object in context.registeredObjects where !object.isFault {
                guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
                return result
            }
            return nil
        }
    }

    /*
    public static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void) async -> Self? {
        let result = await try fetch(in: context) { request in
            configure(request)
            request.fetchLimit = 1
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }
    */

    func updateToOneRelationship<J: Any, T: NSManagedObject & Orphanable>(relationship: String, newValue: J?, newObject: ((J) -> T)? = nil) {
        // Store our old value so we can reference it later
        let oldValue = value(forKeyPath: relationship) as? T

        // The ol' switcharoo
        if let newValue = newValue, let newObject = newObject {
            setValue(newObject(newValue), forKeyPath: relationship)
        } else {
            setValue(nil, forKeyPath: relationship)
        }

        // Clean up orphan, if applicable
        if let oldValue = oldValue, oldValue.isOrphaned {
            managedObjectContext?.delete(oldValue)
        }
    }

    func updateToManyRelationship<T: NSManagedObject & Orphanable>(relationship: String, newValues new: [T]?) async throws {
        guard let managedObjectContext = managedObjectContext else {
            throw TBADataError.missingManagedObjectContext
        }

        let debugString = "\(String(describing: type(of: self))).\(relationship)"
        guard let relationshipAttributeDescription = entity.relationshipsByName[relationship] else {
            throw TBADataError.missingKeyPathValue(debugString)
        }
        assert(relationshipAttributeDescription.isToMany, "Unable to update relationship \(debugString) - relationship must be a To Many relationship")

        let SetClass: SetManaged.Type = {
            if relationshipAttributeDescription.isOrdered {
                return NSOrderedSet.self
            } else {
                return NSSet.self
            }
        }()

        // Store our old values so we can reference them later
        let oldSet = await managedObjectContext.perform { [unowned self] in
            return value(forKeyPath: relationship) as? SetManaged
        }
        let oldValues = oldSet?.items as? [T]

        // The ol' switcharoo
        let newArray = new ?? []
        await managedObjectContext.perform { [unowned self] in
            setValue(SetClass.init(array: newArray), forKey: relationship)
        }

        // Clean up orphans, if applicable
        let newSet = Set(newArray)
        if let oldValues = oldValues {
            let oldSet = Set(oldValues)
            let orphans = oldSet.subtracting(newSet).filter({ $0.isOrphaned })
            await managedObjectContext.perform {
                orphans.forEach {
                    managedObjectContext.delete($0)
                }
            }
        }
    }

}

private protocol SetManaged {
    init(array: [Any])
    var items: [Any] { get }
}

extension NSSet: SetManaged {
    var items: [Any] {
        return allObjects
    }
}

extension NSOrderedSet: SetManaged {
    var items: [Any] {
        return array
    }
}
