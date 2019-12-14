import CoreData
import Foundation
import TBAKit
import TBAUtils

@objc(EventAlliance)
public class EventAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventAlliance> {
        return NSFetchRequest<EventAlliance>(entityName: EventAlliance.entityName)
    }

    @NSManaged public private(set) var name: String?

    public var event: Event {
        guard let event = eventOne else {
            fatalError("Save EventAlliance before accessing event")
        }
        return event
    }

    @NSManaged public private(set) var backup: EventAllianceBackup?
    @NSManaged public private(set) var declines: NSOrderedSet?
    @NSManaged private var eventOne: Event?
    @NSManaged public private(set) var picks: NSOrderedSet?
    @NSManaged public private(set) var status: EventStatusPlayoff?

}

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
    public static func insert(_ model: TBAAlliance, eventKey: String, in context: NSManagedObjectContext) -> EventAlliance {
        let predicate = NSPredicate(format: "%K.%K == %@ AND SUBQUERY(%K, $pick, $pick.%K IN %@).@count == %d",
                                    EventAlliance.eventKeyPath(), Event.keyPath(), eventKey,
                                    EventAlliance.picksKeyPath(), #keyPath(Team.keyString), model.picks, model.picks.count)

        return findOrCreate(in: context, matching: predicate, configure: { (alliance) in
            // Required: picks
            alliance.name = model.name

            alliance.updateToOneRelationship(relationship: #keyPath(EventAlliance.backup), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })

            alliance.picks = NSOrderedSet(array: model.picks.map {
                return Team.insert($0, in: context)
            })

            if let declines = model.declines {
                alliance.declines = NSOrderedSet(array: declines.map {
                    return Team.insert($0, in: context)
                })
            } else {
                alliance.declines = nil
            }

            if let teamKey = model.picks.first {
                alliance.updateToOneRelationship(relationship: #keyPath(EventAlliance.status), newValue: model.status, newObject: {
                    return EventStatusPlayoff.insert($0, eventKey: eventKey, teamKey: teamKey, in: context)
                })
            } else {
                if let status = alliance.status {
                    context.delete(status)
                }
                alliance.status = nil
            }
        })
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
            if backup.alliances.onlyObject(self) && backup.allianceStatus == nil {
                // AllianceBackup will become an orphan - delete
                managedObjectContext?.delete(backup)
            } else {
                backup.removeFromAlliancesMany(self)
            }
        }
    }

}

extension EventAlliance {

    public static func eventKeyPath() -> String {
        return #keyPath(EventAlliance.eventOne)
    }

    public static func picksKeyPath() -> String {
        return #keyPath(EventAlliance.picks)
    }

}

extension EventAlliance: Orphanable {

    var isOrphaned: Bool {
        return eventOne == nil
    }

}
