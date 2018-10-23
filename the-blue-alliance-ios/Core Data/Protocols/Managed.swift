import CoreData

public protocol Managed: class, NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

extension Managed where Self: NSManagedObject {

    public static var entity: NSEntityDescription { return entity()  }

    public static var entityName: String { return entity.name!  }

    public static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> Void) -> Self {
        var object = findOrFetch(in: context, matching: predicate)
        if object == nil {
            object = context.insertObject()
        }
        configure(object!)
        return object!
    }

    public static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return object
    }

    public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }

    public static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void = { _ in }) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return try! context.count(for: request)
    }

    public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }

    public static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void) -> Self? {
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

    public static func updateToOneRelationship<J: Any, T: NSManagedObject>(relationship: inout T?, newValue: J?, newObject: (J) -> T) {
        if let newValue = newValue {
            relationship = newObject(newValue)
        } else {
            relationship = nil
        }
    }

    public static func updateToManyRelationship<T: NSManagedObject>(relationship: inout NSSet?, newValues new: [T], matchingOrphans: @escaping (T) -> Bool, in context: NSManagedObjectContext) {
        // Store our old values so we can reference them later
        let oldValues = relationship?.allObjects as? [T]

        // The ol' switcharoo
        let newSet = Set(new)
        relationship = newSet as NSSet

        // Clean up orphans, if applicable
        if let oldValues = oldValues {
            let oldSet = Set(oldValues)
            oldSet.subtracting(newSet).filter(matchingOrphans).forEach({
                context.delete($0)
            })
        }
    }

}
