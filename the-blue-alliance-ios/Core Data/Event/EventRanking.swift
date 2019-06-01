import CoreData
import Foundation
import TBAKit

extension EventRanking: Managed {

    var extraStatsInfoArray: [EventRankingStatInfo]? {
        return extraStatsInfo?.array as? [EventRankingStatInfo]
    }
    var extraStatsArray: [EventRankingStat]? {
        return extraStats?.array as? [EventRankingStat]
    }
    var sortOrdersInfoArray: [EventRankingStatInfo]? {
        return sortOrdersInfo?.array as? [EventRankingStatInfo]
    }
    var sortOrdersArray: [EventRankingStat]? {
        return sortOrders?.array as? [EventRankingStat]
    }

    private func statString(statsInfo: [EventRankingStatInfo]?, stats: [EventRankingStat]?) -> String? {
        guard let statsInfo = statsInfo, let stats = stats else {
            return nil
        }
        let parts = zip(statsInfo, stats).map({ (statsTuple) -> String? in
            let (statInfo, stat) = statsTuple
            guard let value = stat.value else {
                return nil
            }
            guard let name = statInfo.name else {
                return nil
            }
            let precision = Int(statInfo.precision)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = precision
            numberFormatter.minimumFractionDigits = precision

            guard let valueString = numberFormatter.string(from: value) else {
                return nil
            }
            return "\(name): \(valueString)"
        }).compactMap({ $0 })
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    /// Description for an EventRanking's extraStats/sortOrders (ranking/tiebreaker names/values) as a comma separated string.
    var rankingInfoString: String? {
        get {
            let rankingInfoStringParts = [(extraStatsInfoArray, extraStatsArray), (sortOrdersInfoArray, sortOrdersArray)].map({ (tuple) -> String? in
                let (statsInfo, stats) = tuple
                return statString(statsInfo: statsInfo, stats: stats)
            }).compactMap({ $0 })
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

            // Extra Stats exists on objects returned by /event/{event_key}/rankings
            // but not on models returned by /team/{team_key}/event/{event_key} `Team_Event_Status_rank` model
            // (This is true for any endpoint that returns a `Team_Event_Status_rank` model)
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.extraStatsInfo), newValues: extraStatsInfo?.map({
                return EventRankingStatInfo.insert($0, in: context)
            }))
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.extraStats), newValues: model.extraStats?.map({
                return EventRankingStat.insert(value: $0, extraStatsRanking: ranking, in: context)
            }))
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.sortOrdersInfo), newValues: sortOrderInfo?.map({
                return EventRankingStatInfo.insert($0, in: context)
            }))
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.sortOrders), newValues: model.sortOrders?.map({
                return EventRankingStat.insert(value: $0, sortOrderRanking: ranking, in: context)
            }))
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

        // Loop twice - once to cleanup our relationships, once to delete.
        // Note to Zach: Test this with only one loop and confirm it doesn't work
        extraStatsInfoArray?.forEach({
            guard let extraStatsRankings = $0.extraStatsRankings else {
                return
            }
            if extraStatsRankings.onlyObject(self) {
                // Only mark for deletion if our sets are thinned out
                guard let sortOrderRankings = $0.sortOrdersRankings else {
                    // No sortOrderRankings - we're good for deletion
                    managedObjectContext?.delete($0)
                    return
                }
                if sortOrderRankings.onlyObject(self) || sortOrderRankings.count == 0 {
                    managedObjectContext?.delete($0)
                }
            } else {
                $0.removeFromExtraStatsRankings(self)
            }
        })

        // Same as above (hopefully)
        sortOrdersInfoArray?.forEach({
            guard let sortOrderRankings = $0.sortOrdersRankings else {
                return
            }
            if sortOrderRankings.onlyObject(self) {
                guard let extraStatsRankings = $0.extraStatsRankings else {
                    // No extraStatsRankings - we're good for deletion
                    managedObjectContext?.delete($0)
                    return
                }
                if extraStatsRankings.onlyObject(self) || extraStatsRankings.count == 0 {
                    managedObjectContext?.delete($0)
                }
            } else {
                $0.removeFromSortOrdersRankings(self)
            }
        })
    }

}
