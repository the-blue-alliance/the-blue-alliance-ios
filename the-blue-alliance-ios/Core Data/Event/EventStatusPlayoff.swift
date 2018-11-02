import CoreData
import Foundation
import TBAKit

extension EventStatusPlayoff: Managed {

    /**
     How far an alliance got in the eliminiations.

     Used in EventAllianceTableViewCell.
     */
    var allianceLevel: String? {
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

    static func insert(_ model: TBAAllianceStatus, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusPlayoff {
        let predicate = NSPredicate(format: "(%K == %@ AND SUBQUERY(%K, $pick, $pick.key == %@).@count == 1) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusPlayoff.alliance.event.key), eventKey,
                                    #keyPath(EventStatusPlayoff.alliance.picks), teamKey,
                                    #keyPath(EventStatusPlayoff.eventStatus.event.key), eventKey,
                                    #keyPath(EventStatusPlayoff.eventStatus.teamKey.key), teamKey)

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

    var isOrphaned: Bool {
        // An EventStatusPlayoff is an orphan if it isn't attached to any EventAlliance or an EventStatus.
        let hasAlliance = (alliance != nil)
        let hasStatus = (eventStatus != nil)
        return !hasAlliance && !hasStatus
    }

}
