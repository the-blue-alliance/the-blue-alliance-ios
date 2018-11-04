import Foundation
import TBAKit
import CoreData

extension EventRanking: Managed {

    /// Description for an EventRanking's sortOrders (tiebreaker names/values) as a comma separated string.
    var tiebreakerInfoString: String? {
        get {
            if let tiebreakerValues = tiebreakerValues, !tiebreakerValues.isEmpty, let tiebreakerNames = tiebreakerNames, !tiebreakerNames.isEmpty {
                var infoParts: [String] = []
                for (sortOrderName, sortOrderValue) in zip(tiebreakerNames, tiebreakerValues) {
                    infoParts.append("\(sortOrderName): \(sortOrderValue)")
                }
                return infoParts.joined(separator: ", ")
            }
            return nil
        }
    }

    static func insert(_ model: TBAEventRanking, sortOrderInfo: [TBAEventRankingSortOrder]?, extraStatsInfo: [TBAEventRankingSortOrder]?, eventKey: String, in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "(%K == %@ OR %K == %@) AND %K == %@",
                                    #keyPath(EventRanking.event.key), eventKey,
                                    #keyPath(EventRanking.qualStatus.eventStatus.event.key), eventKey,
                                    #keyPath(EventRanking.teamKey.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            // Required: teamKey, rank
            ranking.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
            ranking.dq = model.dq as NSNumber?
            ranking.matchesPlayed = model.matchesPlayed as NSNumber?
            ranking.qualAverage = model.qualAverage as NSNumber?
            ranking.rank = model.rank as NSNumber

            if let record = model.record {
                ranking.record = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
            } else {
                ranking.record = nil
            }

            if let tiebreakerValues = model.sortOrders, !tiebreakerValues.isEmpty {
                ranking.tiebreakerValues = tiebreakerValues
            } else {
                ranking.tiebreakerValues = nil
            }

            if let sortOrderInfo = sortOrderInfo {
                let tiebreakerNames = sortOrderInfo.map { $0.name }
                if !tiebreakerNames.isEmpty {
                    ranking.tiebreakerNames = tiebreakerNames
                }
            } else {
                ranking.tiebreakerNames = nil
            }

            // Extra Stats exists on objects returned by /event/{event_key}/rankings
            // but not on models returned by /team/{team_key}/event/{event_key} `Team_Event_Status_rank` model
            // (This is true for any endpoint that returns a `Team_Event_Status_rank` model)
            if let extraStatsValues = model.extraStats, !extraStatsValues.isEmpty {
                ranking.extraStatsValues = extraStatsValues
            }

            if let extraStatsInfo = extraStatsInfo {
                let extraStatsNames = extraStatsInfo.map { $0.name }
                if !extraStatsNames.isEmpty {
                    ranking.extraStatsNames = extraStatsNames
                }
            }
        })
    }

    var isOrphaned: Bool {
        // Ranking is an orphan if it's not attached to an Event or a EventStatusQual
        let hasEvent = (event != nil)
        let hasStatus = (qualStatus != nil)
        return !hasEvent && !hasStatus
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let qualStatus = qualStatus {
            if qualStatus.eventStatus == nil {
                // qualStatus will become an orphan - delete
                managedObjectContext?.delete(qualStatus)
            } else {
                qualStatus.ranking = nil
            }
        }
    }

}
