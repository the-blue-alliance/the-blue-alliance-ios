import CoreData
import Foundation
import TBAKit

extension EventStatusAlliance {

    public var name: String? {
        return getValue(\EventStatusAlliance.nameRaw)
    }

    public var number: Int {
        guard let number = getValue(\EventStatusAlliance.numberRaw)?.intValue else {
            fatalError("Save EventStatusAlliance before accessing number")
        }
        return number
    }

    public var pick: Int {
        guard let pick = getValue(\EventStatusAlliance.pickRaw)?.intValue else {
            fatalError("Save EventStatusAlliance before accessing pick")
        }
        return pick
    }

    public var backup: EventAllianceBackup? {
        return getValue(\EventStatusAlliance.backupRaw)
    }

    public var eventStatus: EventStatus {
        guard let eventStatus = getValue(\EventStatusAlliance.eventStatusRaw) else {
            fatalError("Save EventStatusAlliance before accessing eventStatus")
        }
        return eventStatus
    }

}

@objc(EventStatusAlliance)
public class EventStatusAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusAlliance> {
        return NSFetchRequest<EventStatusAlliance>(entityName: EventStatusAlliance.entityName)
    }

    @NSManaged var nameRaw: String?
    @NSManaged var numberRaw: NSNumber?
    @NSManaged var pickRaw: NSNumber?
    @NSManaged var backupRaw: EventAllianceBackup?
    @NSManaged var eventStatusRaw: EventStatus?

}

extension EventStatusAlliance: Managed {

    public static func insert(_ model: TBAEventStatusAlliance, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatusAlliance.eventStatusRaw.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventStatusAlliance.eventStatusRaw.teamRaw.keyRaw), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.numberRaw = NSNumber(value: model.number)
            allianceStatus.pickRaw = NSNumber(value: model.pick)
            allianceStatus.nameRaw = model.name

            allianceStatus.updateToOneRelationship(relationship: #keyPath(EventStatusAlliance.backupRaw), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })
        })
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let backup = backup {
            if backup.alliances.count == 0 && backup.allianceStatus == self {
                // AllianceBackup will become an orphan - delete
                managedObjectContext?.delete(backup)
            } else {
                backup.allianceStatusRaw = nil
            }
        }
    }

}

extension EventStatusAlliance: Orphanable {

    public var isOrphaned: Bool {
        return eventStatusRaw == nil
    }

}
