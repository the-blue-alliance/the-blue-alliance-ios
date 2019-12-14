import CoreData
import Foundation
import TBAKit

@objc(EventRanking)
public class EventRanking: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRanking> {
        return NSFetchRequest<EventRanking>(entityName: EventRanking.entityName)
    }

    public var dq: Int? {
        return dqNumber?.intValue
    }

    public var matchesPlayed: Int? {
        return matchesPlayedNumber?.intValue
    }

    public var qualAverage: Double? {
        return qualAverageNumber?.doubleValue
    }

    public var rank: Int {
        guard let rank = rankNumber?.intValue else {
            fatalError("Save EventRanking before accessing rank")
        }
        return rank
    }

    public var event: Event {
        guard let event = eventOne else {
            fatalError("Save EventRanking before accessing event")
        }
        return event
    }

    public var team: Team {
        guard let team = teamOne else {
            fatalError("Save EventRanking before accessing team")
        }
        return team
    }

    @NSManaged var dqNumber: NSNumber?
    @NSManaged var matchesPlayedNumber: NSNumber?
    @NSManaged var qualAverageNumber: NSNumber?
    @NSManaged var rankNumber: NSNumber?
    @NSManaged var record: WLT?
    @NSManaged var eventOne: Event?
    @NSManaged var extraStats: NSOrderedSet?
    @NSManaged var extraStatsInfo: NSOrderedSet?
    @NSManaged var qualStatus: EventStatusQual?
    @NSManaged var sortOrders: NSOrderedSet?
    @NSManaged var sortOrdersInfo: NSOrderedSet?
    @NSManaged var teamOne: Team?

}

extension EventRanking: Managed {

    public static func insert(_ model: TBAEventRanking, sortOrderInfo: [TBAEventRankingSortOrder]?, extraStatsInfo: [TBAEventRankingSortOrder]?, eventKey: String, in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "(%K == %@ OR %K == %@) AND %K == %@",
                                    #keyPath(EventRanking.eventOne.keyRaw), eventKey,
                                    #keyPath(EventRanking.qualStatus.eventStatus.eventOne.keyRaw), eventKey,
                                    #keyPath(EventRanking.teamOne.keyString), model.teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            // Required: teamKey, rank
            ranking.teamOne = Team.insert(model.teamKey, in: context)
            if let dq = model.dq {
                ranking.dqNumber = NSNumber(value: dq)
            } else {
                ranking.dqNumber = nil
            }
            if let matchesPlayed = model.matchesPlayed {
                ranking.matchesPlayedNumber = NSNumber(value: matchesPlayed)
            } else {
                ranking.matchesPlayedNumber = nil
            }
            if let qualAverage = model.qualAverage {
                ranking.qualAverageNumber = NSNumber(value: qualAverage)
            } else {
                ranking.qualAverageNumber = nil
            }
            ranking.rankNumber = NSNumber(value: model.rank)

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
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.extraStats), newValues: model.extraStats?.map {
                return EventRankingStat.insert(value: $0.doubleValue, extraStatsRanking: ranking, in: context)
            })
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.sortOrdersInfo), newValues: sortOrderInfo?.map {
                return EventRankingStatInfo.insert($0, in: context)
            })
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.sortOrders), newValues: model.sortOrders?.map {
                return EventRankingStat.insert(value: $0.doubleValue, sortOrderRanking: ranking, in: context)
            })
        })
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
        // We can't delete when we clean up our relationships, since we need to clean up
        // extraStatsInfoArray and sortOrdersInfoArray independently, and one EventRankingStatInfo
        // could be connected to both an EventRanking extraStatsInfoArray and sortOrdersInfoArray.
        // We need to drop relationships from both, then see if it's an orphan after.

        // Store all of our StatInfo objects - once we drop the relationship between
        // the EventRanking <-> the EventRankingStatInfo, we won't be able to check to
        // see if they're orphans by using the relationships on EventRanking. This allows
        // us to have a list of items we should check to see if they're orphaned.
        var stats = Set(extraStatsInfoArray)
        stats.formUnion(sortOrdersInfoArray)

        // First pass - clean up our relationships.
        extraStatsInfoArray.forEach({
            $0.removeFromExtraStatsRankingsMany(self)
        })
        sortOrdersInfoArray.forEach({
            $0.removeFromSortOrdersRankingsMany(self)
        })

        // Second pass - clean up orphaned EventRankingStatInfo objects that used to be connected to this EventRanking.
        stats.forEach({
            guard $0.isOrphaned else {
                return
            }
            managedObjectContext?.delete($0)
        })
    }

}

extension EventRanking {

    public static func eventKeyPath() -> String {
        return #keyPath(EventRanking.eventOne)
    }

    public static func teamKeyPath() -> String {
        return #keyPath(EventRanking.teamOne)
    }

    public static func rankSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventRanking.rankNumber), ascending: true)
    }

    public var extraStatsInfoArray: [EventRankingStatInfo] {
        return extraStatsInfo?.array as? [EventRankingStatInfo] ?? []
    }
    public var extraStatsArray: [EventRankingStat] {
        return extraStats?.array as? [EventRankingStat] ?? []
    }
    public var sortOrdersInfoArray: [EventRankingStatInfo] {
        return sortOrdersInfo?.array as? [EventRankingStatInfo] ?? []
    }
    public var sortOrdersArray: [EventRankingStat] {
        return sortOrders?.array as? [EventRankingStat] ?? []
    }

    private func statString(statsInfo: [EventRankingStatInfo], stats: [EventRankingStat]) -> String? {
        let parts = zip(statsInfo, stats).map({ (statsTuple) -> String? in
            let (statInfo, stat) = statsTuple
            let precision = Int(statInfo.precision)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = precision
            numberFormatter.minimumFractionDigits = precision

            guard let valueString = numberFormatter.string(for: stat.value) else {
                return nil
            }
            return "\(statInfo.name): \(valueString)"
        }).compactMap({ $0 })
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    /// Description for an EventRanking's extraStats/sortOrders (ranking/tiebreaker names/values) as a comma separated string.
    public var rankingInfoString: String? {
        get {
            let rankingInfoStringParts = [(extraStatsInfoArray, extraStatsArray), (sortOrdersInfoArray, sortOrdersArray)].map({ (tuple) -> String? in
                let (statsInfo, stats) = tuple
                return statString(statsInfo: statsInfo, stats: stats)
            }).compactMap({ $0 })
            return rankingInfoStringParts.isEmpty ? nil : rankingInfoStringParts.joined(separator: ", ")
        }
    }

    public func setEvent(event: Event) {
        self.eventOne = event
    }

}

extension EventRanking: Orphanable {

    public var isOrphaned: Bool {
        // Ranking is an orphan if it's not attached to an Event or a EventStatusQual
        let hasEvent = (eventOne != nil)
        let hasStatus = (qualStatus != nil)
        return !hasEvent && !hasStatus
    }

}
