import CoreData
import Foundation
import TBAKit

extension EventRanking: Managed {

    /// Description for an EventRanking's extraStats/sortOrders (ranking/tiebreaker names/values) as a comma separated string.
    var rankingInfoString: String? {
        get {
            let rankingInformation: [([String]?, [NSNumber]?)] = [(extraStatsNames, extraStatsValues), (tiebreakerNames, tiebreakerValues)]
            var rankingInfoStringParts: [String] = []
            for (names, values) in rankingInformation {
                guard let names = names, !names.isEmpty, let values = values, !values.isEmpty else {
                    continue
                }
                var infoParts: [String] = []
                for (name, value) in zip(names, values) {
                    infoParts.append("\(name): \(value)")
                }
                rankingInfoStringParts.append(infoParts.joined(separator: ", "))
            }
            return rankingInfoStringParts.isEmpty ? nil : rankingInfoStringParts.joined(separator: ", ")
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
                // Note: We get rid of precision, because... we probably don't need it
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
                // Note: We get rid of precision, because... we probably don't need it
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
