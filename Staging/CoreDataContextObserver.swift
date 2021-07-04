import Foundation
import CoreData

public struct CoreDataContextObserverState: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let inserted  = CoreDataContextObserverState(rawValue: 1 << 0)
    public static let updated   = CoreDataContextObserverState(rawValue: 1 << 1)
    public static let deleted   = CoreDataContextObserverState(rawValue: 1 << 2)
    public static let all: CoreDataContextObserverState = [inserted, updated, deleted]

    public static let allList: [CoreDataContextObserverState] = [inserted, updated, deleted]
}

public struct CoreDataObserverAction<T: NSManagedObject> {
    var state: CoreDataContextObserverState
    var completionBlock: (T, CoreDataContextObserverState) -> Void
}

public class CoreDataContextObserver<T: NSManagedObject> {
    public var enabled: Bool = true

    private var notificationObserver: NSObjectProtocol?
    private(set) var context: NSManagedObjectContext

    // Dictionary of "actions" (state, completion block) for all actions (inserts, updates, deletes, refreshes)
    private(set) var actionsForManagedObjectID = Dictionary<NSManagedObjectID, [CoreDataObserverAction<T>]>()

    // Observe Insertions for VERY specific objects...
    // Call completion block when inserted objects match predicate
    private(set) var insertionPredicate: NSPredicate?
    // Completion blocks for only insertions actions - can only have one block for this
    private(set) var completionForInsertedManagedObjectID: ((Set<T>) -> Void)?

    private(set) weak var persistentStoreCoordinator: NSPersistentStoreCoordinator?

    deinit {
        unobserveAllObjects()
        unobserveInsertions()
        if let notificationObserver = notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }

    public init(context: NSManagedObjectContext) {
        self.context = context
        self.persistentStoreCoordinator = context.persistentStoreCoordinator

        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: nil, using: { [weak self] (notification) in
            self?.handleContextObjectDidChangeNotification(notification: notification)
        })
    }

    private func handleContextObjectDidChangeNotification(notification: Notification) {
        guard let incomingContext = notification.object as? NSManagedObjectContext,
            let persistentStoreCoordinator = persistentStoreCoordinator,
            let incomingPersistentStoreCoordinator = incomingContext.persistentStoreCoordinator, enabled, persistentStoreCoordinator == incomingPersistentStoreCoordinator else {
                return
        }

        // This assumes we won't get multiple calls by having an object in more than one set (which should be true?)
        // Ex: If an object is inserted and deleted before we get the notification, we'll call this twice
        let objectKeys = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey]
        for (key, state) in zip(objectKeys, CoreDataContextObserverState.allList) {
            let objectsSet: Set<NSManagedObject> = {
                let objectsSet = notification.userInfo?[key] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
                if state == .updated {
                    // Treat refreshed objects as being updated - which is fine for our use case right now
                    let refreshedSet = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()

                    let thirdSet = NSMutableSet(set: objectsSet)
                    return thirdSet.addingObjects(from: refreshedSet) as! Set<NSManagedObject>
                }
                return objectsSet
            }()

            // Handle Insertion observers
            if state == .inserted, let completionBlock = completionForInsertedManagedObjectID {
                // Filter objects that match predicate (or all objects), then call the completion block for each object
                let filteredObjectSet = objectsSet.filter({ ($0 as? T) != nil }).filter({ insertionPredicate?.evaluate(with: $0) ?? true })
                if let filteredInsertions = filteredObjectSet as? Set<T>, filteredObjectSet.count > 0 {
                    completionBlock(filteredInsertions)
                }
            }

            for case let object as T in objectsSet {
                guard let actionsForObject = actionsForManagedObjectID[object.objectID] else { continue }
                actionsForObject.filter({ $0.state == state || $0.state == .all }).forEach({ $0.completionBlock(object, state) })
            }
        }
    }

    public func observeObject(object: NSManagedObject, state: CoreDataContextObserverState = .all, completionBlock: @escaping (T, CoreDataContextObserverState) -> Void) {
        // Side effect - only allow observing insertions OR updates
        unobserveInsertions()

        let action = CoreDataObserverAction<T>(state: state, completionBlock: completionBlock)
        if var actionArray: [CoreDataObserverAction<T>] = actionsForManagedObjectID[object.objectID] {
            actionArray.append(action)
            actionsForManagedObjectID[object.objectID] = actionArray
        } else {
            actionsForManagedObjectID[object.objectID] = [action]
        }
    }

    public func unobserveObject(object: NSManagedObject, forState state: CoreDataContextObserverState = .all) {
        if state == .all {
            actionsForManagedObjectID.removeValue(forKey: object.objectID)
        } else if let actionsForObject = actionsForManagedObjectID[object.objectID] {
            actionsForManagedObjectID[object.objectID] = actionsForObject.filter({ !$0.state.contains(state) })
        }
    }

    public func observeInsertions(matchingPredicate predicate: NSPredicate? = nil, completionBlock: @escaping (Set<T>) -> Void) {
        // Side effect - only allow observing insertions OR updates
        unobserveAllObjects()

        insertionPredicate = predicate
        completionForInsertedManagedObjectID = completionBlock
    }

    public func unobserveInsertions() {
        insertionPredicate = nil
        completionForInsertedManagedObjectID = nil
    }

    public func unobserveAllObjects() {
        actionsForManagedObjectID.removeAll()
    }
}
