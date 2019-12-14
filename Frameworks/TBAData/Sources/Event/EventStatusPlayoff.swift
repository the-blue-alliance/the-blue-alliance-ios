import CoreData
import Foundation
import TBAKit

@objc(EventStatusPlayoff)
public class EventStatusPlayoff: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusPlayoff> {
        return NSFetchRequest<EventStatusPlayoff>(entityName: EventStatusPlayoff.entityName)
    }

    public var playoffAverage: Double? {
        return playoffAverageNumber?.doubleValue
    }

    @NSManaged var currentRecord: WLT?
    @NSManaged var level: String?
    @NSManaged var playoffAverageNumber: NSNumber?
    @NSManaged var record: WLT?
    @NSManaged var status: String?
    @NSManaged var alliance: EventAlliance?
    @NSManaged var eventStatus: EventStatus?

}

extension EventStatusPlayoff: Managed {

    public static func insert(_ model: TBAAllianceStatus, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusPlayoff {
        let predicate = NSPredicate(format: "(%K == %@ AND SUBQUERY(%K, $pick, $pick.%K == %@).@count == 1) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusPlayoff.alliance.eventOne.keyRaw), eventKey,
                                    #keyPath(EventStatusPlayoff.alliance.picks), #keyPath(Team.keyString), teamKey,
                                    #keyPath(EventStatusPlayoff.eventStatus.eventOne.keyRaw), eventKey,
                                    #keyPath(EventStatusPlayoff.eventStatus.teamOne.keyString), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (statusPlayoff) in
            if let currentRecord = model.currentRecord {
                statusPlayoff.currentRecord = WLT(wins: currentRecord.wins, losses: currentRecord.losses, ties: currentRecord.ties)
            } else {
                statusPlayoff.currentRecord = nil
            }

            statusPlayoff.level = model.level
            if let playoffAverage = model.playoffAverage {
                statusPlayoff.playoffAverageNumber = NSNumber(value: playoffAverage)
            } else {
                statusPlayoff.playoffAverageNumber = nil
            }

            if let record = model.record {
                statusPlayoff.record = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
            } else {
                statusPlayoff.record = nil
            }

            statusPlayoff.status = model.status
        })
    }

}

extension EventStatusPlayoff {

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

extension EventStatusPlayoff: Orphanable {

    public var isOrphaned: Bool {
        // An EventStatusPlayoff is an orphan if it isn't attached to any EventAlliance or an EventStatus.
        let hasAlliance = (alliance != nil)
        let hasStatus = (eventStatus != nil)
        return !hasAlliance && !hasStatus
    }

}
