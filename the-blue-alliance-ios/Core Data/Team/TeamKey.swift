import CoreData

/**
 A TeamKey is an object used to represent just a team key returned from an API call. This allows us to keep
 relationships between objects and team representations, without having to store full team objects (we may not have)
 or store arrays of keys (which we can't filter against).

 A TeamKey is a VERY specific model. If you're not use if you need a TeamKey or a Team, you probably need a Team.
 */
extension TeamKey: Managed {

    /**
     The Team object in the managed object context with the same key as the TeamKey.
     */
    var team: Team? {
        return Team.findOrFetch(in: managedObjectContext!, matching: Team.predicate(key: key!))
    }

    /**
     A placeholder team number for a Team. Derived from the team's key, not guarenteed to be a number.

     An example of when this wouldn't be a number would be for an offseason event when a team's key is `frc7332B`. The teamNumber would be `7332B`
     */
    var teamNumber: String {
        return Team.trimFRCPrefix(key!)
    }

    /**
     A placeholder name for a Team - will be in the format 'Team ####'
     */
    var name: String {
        return "Team \(teamNumber)"
    }

    /**
     Insert a TeamKey with a specified key in to the managed object context.

     - Parameter key: The key for the TeamKey.

     - Parameter context: The NSManagedContext to insert the TeamKey in to.

     - Returns: The inserted TeamKey.
     */
    static func insert(withKey key: String, in context: NSManagedObjectContext) -> TeamKey {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TeamKey.key), key)

        return findOrCreate(in: context, matching: predicate) { (teamKey) in
            // Required: key
            teamKey.key = key
        }
    }

    var isOrphaned: Bool {
        // TeamKey should never be an orphan
        return false
    }

}
