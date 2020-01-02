import CoreData
import Foundation
import TBAKit

extension EventRanking {

    public var dq: Int? {
        return getValue(\EventRanking.dqRaw)?.intValue
    }

    public var matchesPlayed: Int? {
        return getValue(\EventRanking.matchesPlayedRaw)?.intValue
    }

    public var qualAverage: Double? {
        return getValue(\EventRanking.qualAverageRaw)?.doubleValue
    }

    public var rank: Int {
        guard let rank = getValue(\EventRanking.rankRaw)?.intValue else {
            fatalError("Save EventRanking before accessing rank")
        }
        return rank
    }

    public var record: WLT? {
        return getValue(\EventRanking.recordRaw)
    }

    public var event: Event {
        guard let event = getValue(\EventRanking.eventRaw) else {
            fatalError("Save EventRanking before accessing event")
        }
        return event
    }

    // TODO: Pretty sure these NSOrderedSet will never be nil
    public var extraStats: NSOrderedSet? {
        return getValue(\EventRanking.extraStatsRaw)
    }

    public var extraStatsInfo: NSOrderedSet? {
        return getValue(\EventRanking.extraStatsInfoRaw)
    }

    public var qualStatus: EventStatusQual? {
        return getValue(\EventRanking.qualStatusRaw)
    }

    public var sortOrders: NSOrderedSet? {
        return getValue(\EventRanking.sortOrdersRaw)
    }

    public var sortOrdersInfo: NSOrderedSet? {
        return getValue(\EventRanking.sortOrdersInfoRaw)
    }

    public var team: Team {
        guard let team = getValue(\EventRanking.teamRaw) else {
            fatalError("Save EventRanking before accessing team")
        }
        return team
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

}

@objc(EventRanking)
public class EventRanking: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRanking> {
        return NSFetchRequest<EventRanking>(entityName: EventRanking.entityName)
    }

    @NSManaged var dqRaw: NSNumber?
    @NSManaged var matchesPlayedRaw: NSNumber?
    @NSManaged var qualAverageRaw: NSNumber?
    @NSManaged var rankRaw: NSNumber?
    @NSManaged var recordRaw: WLT?
    @NSManaged var eventRaw: Event?
    @NSManaged var extraStatsRaw: NSOrderedSet?
    @NSManaged var extraStatsInfoRaw: NSOrderedSet?
    @NSManaged var qualStatusRaw: EventStatusQual?
    @NSManaged var sortOrdersRaw: NSOrderedSet?
    @NSManaged var sortOrdersInfoRaw: NSOrderedSet?
    @NSManaged var teamRaw: Team?

}

extension EventRanking: Managed {

    public static func insert(_ model: TBAEventRanking, sortOrderInfo: [TBAEventRankingSortOrder]?, extraStatsInfo: [TBAEventRankingSortOrder]?, eventKey: String, in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "(%K == %@ OR %K == %@) AND %K == %@",
                                    #keyPath(EventRanking.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventRanking.qualStatusRaw.eventStatusRaw.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventRanking.teamRaw.keyRaw), model.teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            // Required: teamKey, rank
            ranking.teamRaw = Team.insert(model.teamKey, in: context)
            if let dq = model.dq {
                ranking.dqRaw = NSNumber(value: dq)
            } else {
                ranking.dqRaw = nil
            }
            if let matchesPlayed = model.matchesPlayed {
                ranking.matchesPlayedRaw = NSNumber(value: matchesPlayed)
            } else {
                ranking.matchesPlayedRaw = nil
            }
            if let qualAverage = model.qualAverage {
                ranking.qualAverageRaw = NSNumber(value: qualAverage)
            } else {
                ranking.qualAverageRaw = nil
            }
            ranking.rankRaw = NSNumber(value: model.rank)

            if let record = model.record {
                ranking.recordRaw = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
            } else {
                ranking.recordRaw = nil
            }

            // Extra Stats exists on objects returned by /event/{event_key}/rankings
            // but not on models returned by /team/{team_key}/event/{event_key} `Team_Event_Status_rank` model
            // (This is true for any endpoint that returns a `Team_Event_Status_rank` model)
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.extraStatsInfoRaw), newValues: extraStatsInfo?.map({
                return EventRankingStatInfo.insert($0, in: context)
            }))
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.extraStatsRaw), newValues: model.extraStats?.map {
                return EventRankingStat.insert(value: $0.doubleValue, extraStatsRanking: ranking, in: context)
            })
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.sortOrdersInfoRaw), newValues: sortOrderInfo?.map {
                return EventRankingStatInfo.insert($0, in: context)
            })
            ranking.updateToManyRelationship(relationship: #keyPath(EventRanking.sortOrdersRaw), newValues: model.sortOrders?.map {
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
                qualStatus.rankingRaw = nil
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
            $0.removeFromExtraStatsRankingsRaw(self)
        })
        sortOrdersInfoArray.forEach({
            $0.removeFromSortOrdersRankingsRaw(self)
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
        self.eventRaw = event
    }

}

extension EventRanking {

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(EventRanking.eventRaw.keyRaw), eventKey)
    }

    public static func rankSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventRanking.rankRaw), ascending: true)
    }

}

extension EventRanking: Orphanable {

    public var isOrphaned: Bool {
        // Ranking is an orphan if it's not attached to an Event or a EventStatusQual
        let hasEvent = (eventRaw != nil)
        let hasStatus = (qualStatusRaw != nil)
        return !hasEvent && !hasStatus
    }

}
