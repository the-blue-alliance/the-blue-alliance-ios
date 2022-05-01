import CoreData
import Foundation
import TBAKit
import TBAUtils

extension EventAlliance {

    public var name: String? {
        return getValue(\EventAlliance.nameRaw)
    }

    public var backup: EventAllianceBackup? {
        return getValue(\EventAlliance.backupRaw)
    }

    public var declines: NSOrderedSet {
        guard let declines = getValue(\EventAlliance.declinesRaw) else {
            fatalError("Save EventAlliance before accessing declines")
        }
        return declines
    }

    public var event: Event {
        guard let event = getValue(\EventAlliance.eventRaw) else {
            fatalError("Save EventAlliance before accessing event")
        }
        return event
    }

    public var picks: NSOrderedSet {
        guard let picks = getValue(\EventAlliance.picksRaw) else {
            fatalError("Save EventAlliance before accessing picks")
        }
        return picks
    }

    public var status: EventStatusPlayoff? {
        return getValue(\EventAlliance.statusRaw)
    }

}

@objc(EventAlliance)
public class EventAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventAlliance> {
        return NSFetchRequest<EventAlliance>(entityName: EventAlliance.entityName)
    }

    @NSManaged var nameRaw: String?
    @NSManaged var backupRaw: EventAllianceBackup?
    @NSManaged var declinesRaw: NSOrderedSet?
    @NSManaged var eventRaw: Event?
    @NSManaged var picksRaw: NSOrderedSet?
    @NSManaged var statusRaw: EventStatusPlayoff?

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
        let predicate = NSPredicate(format: "%K == %@ AND SUBQUERY(%K, $pick, $pick.%K IN %@).@count == %d",
                                    #keyPath(EventAlliance.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventAlliance.picksRaw),
                                    #keyPath(Team.keyRaw), model.picks, model.picks.count)
        print(predicate.predicateFormat)

        return findOrCreate(in: context, matching: predicate, configure: { (alliance) in
            // Required: picks
            alliance.nameRaw = model.name

            alliance.updateToOneRelationship(relationship: #keyPath(EventAlliance.backupRaw), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })

            alliance.picksRaw = NSOrderedSet(array: model.picks.map {
                return Team.insert($0, in: context)
            })

            if let declines = model.declines {
                alliance.declinesRaw = NSOrderedSet(array: declines.map {
                    return Team.insert($0, in: context)
                })
            } else {
                alliance.declinesRaw = nil
            }

            if let teamKey = model.picks.first {
                alliance.updateToOneRelationship(relationship: #keyPath(EventAlliance.statusRaw), newValue: model.status, newObject: {
                    return EventStatusPlayoff.insert($0, eventKey: eventKey, teamKey: teamKey, in: context)
                })
            } else {
                if let status = alliance.statusRaw {
                    context.delete(status)
                }
                alliance.statusRaw = nil
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
                status.allianceRaw = nil
            }
        }

        if let backup = backup {
            if backup.alliances.onlyObject(self) && backup.allianceStatus == nil {
                // AllianceBackup will become an orphan - delete
                managedObjectContext?.delete(backup)
            } else {
                backup.removeFromAlliancesRaw(self)
            }
        }
    }

}

extension EventAlliance: Orphanable {

    var isOrphaned: Bool {
        return eventRaw == nil
    }

}
