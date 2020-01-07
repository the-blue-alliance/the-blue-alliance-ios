import CoreData
import Foundation
import TBAKit

extension EventStatus {

    public var allianceStatus: String? {
        return getValue(\EventStatus.allianceStatusRaw)
    }

    public var lastMatchKey: String? {
        return getValue(\EventStatus.lastMatchKeyRaw)
    }

    public var nextMatchKey: String? {
        return getValue(\EventStatus.nextMatchKeyRaw)
    }

    public var overallStatus: String? {
        return getValue(\EventStatus.overallStatusRaw)
    }

    public var playoffStatus: String? {
        return getValue(\EventStatus.playoffStatusRaw)
    }

    public var alliance: EventStatusAlliance? {
        return getValue(\EventStatus.allianceRaw)
    }

    public var event: Event {
        guard let event = getValue(\EventStatus.eventRaw) else {
            fatalError("Save EventStatus before accessing event")
        }
        return event
    }

    public var playoff: EventStatusPlayoff? {
        return getValue(\EventStatus.playoffRaw)
    }

    public var qual: EventStatusQual? {
        return getValue(\EventStatus.qualRaw)
    }

    public var team: Team {
        guard let team = getValue(\EventStatus.teamRaw) else {
            fatalError("Save EventStatus before accessing team")
        }
        return team
    }

}

@objc(EventStatus)
public class EventStatus: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatus> {
        return NSFetchRequest<EventStatus>(entityName: EventStatus.entityName)
    }

    @NSManaged var allianceStatusRaw: String?
    @NSManaged var lastMatchKeyRaw: String?
    @NSManaged var nextMatchKeyRaw: String?
    @NSManaged var overallStatusRaw: String?
    @NSManaged var playoffStatusRaw: String?
    @NSManaged var allianceRaw: EventStatusAlliance?
    @NSManaged var eventRaw: Event?
    @NSManaged var playoffRaw: EventStatusPlayoff?
    @NSManaged var qualRaw: EventStatusQual?
    @NSManaged var teamRaw: Team?

}

extension EventStatus: Managed {

    @discardableResult
    public static func insert(_ model: TBAEventStatus, in context: NSManagedObjectContext) -> EventStatus {
        let predicate = EventStatus.predicate(eventKey: model.eventKey, teamKey: model.teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (eventStatus) in
            eventStatus.teamRaw = Team.insert(model.teamKey, in: context)

            eventStatus.allianceStatusRaw = model.allianceStatusString
            eventStatus.playoffStatusRaw = model.playoffStatusString
            eventStatus.overallStatusRaw = model.overallStatusString

            eventStatus.nextMatchKeyRaw = model.nextMatchKey
            eventStatus.lastMatchKeyRaw = model.lastMatchKey

            eventStatus.updateToOneRelationship(relationship: #keyPath(EventStatus.qualRaw), newValue: model.qual) {
                return EventStatusQual.insert($0, eventKey: model.eventKey, teamKey: model.teamKey, in: context)
            }
            eventStatus.updateToOneRelationship(relationship: #keyPath(EventStatus.allianceRaw), newValue: model.alliance) {
                return EventStatusAlliance.insert($0, eventKey: model.eventKey, teamKey: model.teamKey, in: context)
            }
            eventStatus.updateToOneRelationship(relationship: #keyPath(EventStatus.playoffRaw), newValue: model.playoff) {
                return EventStatusPlayoff.insert($0, eventKey: model.eventKey, teamKey: model.teamKey, in: context)
            }
        })
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let qual = qual {
            if qual.ranking == nil {
                // EventStatusQual will become an orphan - delete
                managedObjectContext?.delete(qual)
            } else {
                qual.eventStatusRaw = nil
            }
        }

        if let playoff = playoff {
            if playoff.alliance == nil {
                // EventStatusPlayoff will become an orphan - delete
                managedObjectContext?.delete(playoff)
            } else {
                playoff.eventStatusRaw = nil
            }
        }
    }

}

extension EventStatus {

    public static func predicate(eventKey: String, teamKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@",
                           #keyPath(EventStatus.eventRaw.keyRaw), eventKey,
                           #keyPath(EventStatus.teamRaw.keyRaw), teamKey)
    }

}
