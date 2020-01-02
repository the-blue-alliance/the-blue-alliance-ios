import Foundation
import CoreData
import TBAKit

extension EventRankingStatInfo {

    public var name: String {
        guard let name = getValue(\EventRankingStatInfo.nameRaw) else {
            fatalError("Save EventRankingStatInfo before accessing name")
        }
        return name
    }

    public var precision: Int {
        guard let precision = getValue(\EventRankingStatInfo.precisionRaw)?.intValue else {
            fatalError("Save EventRankingStatInfo before accessing precision")
        }
        return precision
    }

    public var extraStatsRankings: [EventRanking] {
        guard let extraStatsRankingsRaw = getValue(\EventRankingStatInfo.extraStatsRankingsRaw),
            let extraStatsRankings = extraStatsRankingsRaw.allObjects as? [EventRanking] else {
                return []
        }
        return extraStatsRankings
    }

    public var sortOrdersRankings: [EventRanking] {
        guard let sortOrdersRankingsRaw = getValue(\EventRankingStatInfo.sortOrdersRankingsRaw),
            let sortOrdersRankings = sortOrdersRankingsRaw.allObjects as? [EventRanking] else {
                return []
        }
        return sortOrdersRankings
    }

}

@objc(EventRankingStatInfo)
public class EventRankingStatInfo: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRankingStatInfo> {
        return NSFetchRequest<EventRankingStatInfo>(entityName: EventRankingStatInfo.entityName)
    }

    @NSManaged private var nameRaw: String?
    @NSManaged private var precisionRaw: NSNumber?
    @NSManaged private var extraStatsRankingsRaw: NSSet?
    @NSManaged private var sortOrdersRankingsRaw: NSSet?

}

// MARK: Generated accessors for extraStatsRankingsMany
extension EventRankingStatInfo {

    @objc(removeFromExtraStatsRankingsRawObject:)
    @NSManaged func removeFromExtraStatsRankingsRaw(_ value: EventRanking)

}

// MARK: Generated accessors for sortOrdersRankingsMany
extension EventRankingStatInfo {

    @objc(removeFromSortOrdersRankingsRawObject:)
    @NSManaged func removeFromSortOrdersRankingsRaw(_ value: EventRanking)

}

extension EventRankingStatInfo: Managed {

    public static func insert(_ model: TBAEventRankingSortOrder, in context: NSManagedObjectContext) -> EventRankingStatInfo {
        let predicate = NSPredicate(format: "%K == %@ && %K == %ld",
                                    #keyPath(EventRankingStatInfo.nameRaw), model.name,
                                    #keyPath(EventRankingStatInfo.precisionRaw), model.precision)

        return findOrCreate(in: context, matching: predicate, configure: { (eventRankingStatInfo) in
            eventRankingStatInfo.nameRaw = model.name
            eventRankingStatInfo.precisionRaw = NSNumber(value: model.precision)
        })
    }

}

extension EventRankingStatInfo: Orphanable {

    public var isOrphaned: Bool {
        return sortOrdersRankings.count == 0 && extraStatsRankings.count == 0
    }

}
