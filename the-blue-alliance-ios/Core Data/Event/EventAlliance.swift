import CoreData
import Foundation
import TBAKit

extension EventAlliance: Managed {

    /**
     Insert an Event Alliance with values from a TBAKit Alliance model in to the managed object context.

     This method manages deleting orphaned EventAllianceBackup and EventStatusPlayoff.

     - Important: This method does not manage setting up an Event Alliance relationship to an Event.

     - Parameter model: The TBAKit Alliance representation to set values from.

     - Parameter eventKey: The Event key the Event Alliance belongs to.

     - Parameter context: The NSManagedContext to insert the District Ranking in to.

     - Returns: The inserted Event Alliance.
     */
    static func insert(_ model: TBAAlliance, eventKey: String, in context: NSManagedObjectContext) -> EventAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND SUBQUERY(picks, $pick, $pick.key IN %@).@count == %d",
                                    #keyPath(EventAlliance.event.key), eventKey,
                                    model.picks, model.picks.count)

        return findOrCreate(in: context, matching: predicate, configure: { (alliance) in
            // Required: picks
            alliance.name = model.name

            alliance.updateToOneRelationship(relationship: #keyPath(EventAlliance.backup), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })

            alliance.picks = NSOrderedSet(array: model.picks.map({ (teamKey) -> TeamKey in
                return TeamKey.insert(withKey: teamKey, in: context)
            }))

            if let declines = model.declines {
                alliance.declines = NSOrderedSet(array: declines.map({ (teamKey) -> TeamKey in
                    return TeamKey.insert(withKey: teamKey, in: context)
                }))
            } else {
                alliance.declines = nil
            }

            let teamKey = model.picks.first!
            alliance.updateToOneRelationship(relationship: #keyPath(EventAlliance.status), newValue: model.status, newObject: {
                return EventStatusPlayoff.insert($0, eventKey: eventKey, teamKey: teamKey, in: context)
            })
        })
    }

    var isOrphaned: Bool {
        return event == nil
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let status = status {
            if status.eventStatus == nil {
                // EventStatusPlayoff will become an orphan - delete
                managedObjectContext?.delete(status)
            } else {
                status.alliance = nil
            }
        }

        if let backup = backup {
            if backup.alliances!.onlyObject(self) && backup.allianceStatus == nil {
                // AllianceBackup will become an orphan - delete
                managedObjectContext?.delete(backup)
            } else {
                backup.removeFromAlliances(self)
            }
        }
    }

}

