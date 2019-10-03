import CoreData

/**
 An EventKey is an object used to represent just a event key returned from an API call. This allows us to keep
 relationships between objects and event representations, without having to store full event objects (we may not have)
 or store arrays of keys (which we can't filter against).

 An EventKey is a VERY specific model. If you're not use if you need an EventKey or an Event, you probably need an Event.

 Currently, EventKey's are only used for DistrictEventPoints, which are related to an Event but may not be loaded before an Event is loaded.
 */
extension EventKey: Managed {

    /**
     The Event object in the managed object context with the same key as the EventKey.
     */
    public var event: Event? {
        return Event.findOrFetch(in: managedObjectContext!, matching: NSPredicate(format: "%K == %@",
                                                                                  #keyPath(Event.key), key!))
    }

    /**
     Insert an EventKey with a specified key in to the managed object context.

     - Parameter key: The key for the EventKey - should relate to an Event key.

     - Parameter context: The NSManagedContext to insert the EventKey in to.

     - Returns: The inserted EventKey.
     */
    public static func insert(withKey key: String, in context: NSManagedObjectContext) -> EventKey {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(EventKey.key), key)

        return findOrCreate(in: context, matching: predicate) { (eventKey) in
            // Required: key
            eventKey.key = key
        }
    }

    public var isOrphaned: Bool {
        // EventKey should never be an orphan
        return false
    }

}
