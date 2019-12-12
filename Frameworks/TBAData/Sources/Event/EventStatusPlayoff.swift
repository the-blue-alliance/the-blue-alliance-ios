import CoreData
import Foundation
import TBAKit

@objc(EventStatusPlayoff)
public class EventStatusPlayoff: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusPlayoff> {
        return NSFetchRequest<EventStatusPlayoff>(entityName: "EventStatusPlayoff")
    }

    @NSManaged public fileprivate(set) var currentRecord: WLT?
    @NSManaged public fileprivate(set) var level: String?
    @NSManaged public fileprivate(set) var playoffAverage: NSNumber?
    @NSManaged public fileprivate(set) var record: WLT?
    @NSManaged public fileprivate(set) var status: String?
    @NSManaged public internal(set) var alliance: EventAlliance?
    @NSManaged public internal(set) var eventStatus: EventStatus?

}

extension EventStatusPlayoff: Managed {

    public static func insert(_ model: TBAAllianceStatus, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusPlayoff {
        // TODO: Use KeyPath https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/162
        let predicate = NSPredicate(format: "(%K == %@ AND SUBQUERY(%K, $pick, $pick.key == %@).@count == 1) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusPlayoff.alliance.event.key), eventKey,
                                    #keyPath(EventStatusPlayoff.alliance.picks), teamKey,
                                    #keyPath(EventStatusPlayoff.eventStatus.event.key), eventKey,
                                    #keyPath(EventStatusPlayoff.eventStatus.team.key), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (statusPlayoff) in
            if let currentRecord = model.currentRecord {
                statusPlayoff.currentRecord = WLT(wins: currentRecord.wins, losses: currentRecord.losses, ties: currentRecord.ties)
            } else {
                statusPlayoff.currentRecord = nil
            }

            statusPlayoff.level = model.level
            statusPlayoff.playoffAverage = model.playoffAverage as NSNumber?

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
