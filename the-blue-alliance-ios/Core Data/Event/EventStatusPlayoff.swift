import CoreData
import Foundation
import TBAKit

// EventAllianceStatus
extension EventStatusPlayoff: Managed {

    // Used in EventAllianceTableViewCell to show how far an alliance got in the eliminiations
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

    static func insert(_ model: TBAAllianceStatus, in context: NSManagedObjectContext) -> EventStatusPlayoff {
        let predicate = NSPredicate()
        return findOrCreate(in: context, matching: predicate, configure: { (statusPlayoff) in

        })
        /*
        if let currentRecord = model.currentRecord {
            self.currentRecord = WLT(wins: currentRecord.wins, losses: currentRecord.losses, ties: currentRecord.ties)
        }

        level = model.level

        if let playoffAverage = model.playoffAverage {
            self.playoffAverage = NSNumber(value: playoffAverage)
        }

        if let record = model.record {
            self.record = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
        }

        status = model.status
        */
    }

    var isOrphaned: Bool {
        // TODO: Fix when we audit
        return false
    }

}
