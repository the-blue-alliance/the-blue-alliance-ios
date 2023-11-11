import CoreData
import Foundation
import TBAKit

extension EventStatusPlayoff {

    public var currentRecord: WLT? {
        return getValue(\EventStatusPlayoff.currentRecordRaw)
    }

    public var level: String? {
        return getValue(\EventStatusPlayoff.levelRaw)
    }

    public var playoffAverage: Double? {
        return getValue(\EventStatusPlayoff.playoffAverageRaw)?.doubleValue
    }

    public var record: WLT? {
        return getValue(\EventStatusPlayoff.recordRaw)
    }

    public var status: String? {
        return getValue(\EventStatusPlayoff.statusRaw)
    }

    public var alliance: EventAlliance? {
        return getValue(\EventStatusPlayoff.allianceRaw)
    }

    public var eventStatus: EventStatus? {
        return getValue(\EventStatusPlayoff.eventStatusRaw)
    }

    /**
     How far an alliance got in the eliminiations.

     Used in EventAllianceTableViewCell.
     */
    public var allianceLevel: String? {
        get {
            guard let level = level else {
                return nil
            }
            if level == MatchCompLevel.final.rawValue, let status = status {
                return status == "won" ? "W" : "F"
            }
            return level.uppercased()
        }
    }

}

@objc(EventStatusPlayoff)
public class EventStatusPlayoff: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusPlayoff> {
        return NSFetchRequest<EventStatusPlayoff>(entityName: EventStatusPlayoff.entityName)
    }

    @NSManaged var currentRecordRaw: WLT?
    @NSManaged var levelRaw: String?
    @NSManaged var playoffAverageRaw: NSNumber?
    @NSManaged var recordRaw: WLT?
    @NSManaged var statusRaw: String?
    @NSManaged var allianceRaw: EventAlliance?
    @NSManaged var eventStatusRaw: EventStatus?

}

extension EventStatusPlayoff: Managed {

    public static func insert(_ model: TBAAllianceStatus, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusPlayoff {
        let predicate = NSPredicate(format: "(%K == %@ AND SUBQUERY(%K, $pick, $pick.%K == %@).@count == 1) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusPlayoff.allianceRaw.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventStatusPlayoff.allianceRaw.picksRaw), #keyPath(Team.keyRaw), teamKey,
                                    #keyPath(EventStatusPlayoff.eventStatusRaw.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventStatusPlayoff.eventStatusRaw.teamRaw.keyRaw), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (statusPlayoff) in
            if let currentRecord = model.currentRecord {
                statusPlayoff.currentRecordRaw = WLT(wins: currentRecord.wins, losses: currentRecord.losses, ties: currentRecord.ties)
            } else {
                statusPlayoff.currentRecordRaw = nil
            }

            statusPlayoff.levelRaw = model.level
            if let playoffAverage = model.playoffAverage {
                statusPlayoff.playoffAverageRaw = NSNumber(value: playoffAverage)
            } else {
                statusPlayoff.playoffAverageRaw = nil
            }

            if let record = model.record {
                statusPlayoff.recordRaw = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
            } else {
                statusPlayoff.recordRaw = nil
            }

            statusPlayoff.statusRaw = model.status
        })
    }

}

extension EventStatusPlayoff: Orphanable {

    public var isOrphaned: Bool {
        // An EventStatusPlayoff is an orphan if it isn't attached to any EventAlliance or an EventStatus.
        let hasAlliance = (allianceRaw != nil)
        let hasStatus = (eventStatusRaw != nil)
        return !hasAlliance && !hasStatus
    }

}
