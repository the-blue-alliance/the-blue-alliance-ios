import CoreData

/**
 A TeamKey is an object used to represent just a team key returned from an API call. This allows us to keep
 relationships between objects and team representations, without having to store full team objects (we may not have)
 or store arrays of keys (which we can't filter against).

 A TeamKey is a VERY specific model. If you're not use if you need a TeamKey or a Team, you probably need a Team.
 */
extension TeamKey: Managed {

    var team: Team? {
        return Team.findOrFetch(in: managedObjectContext!, matching: NSPredicate(format: "key == %@", key!))
    }

    static func insert(withKey key: String, in context: NSManagedObjectContext) -> TeamKey {
        let predicate = NSPredicate(format: "key == %@", key)
        return findOrCreate(in: context, matching: predicate) { (teamKey) in
            // Required: key
            teamKey.key = key
        }
    }

}
