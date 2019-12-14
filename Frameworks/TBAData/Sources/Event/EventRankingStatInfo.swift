import Foundation
import CoreData
import TBAKit

@objc(EventRankingStatInfo)
public class EventRankingStatInfo: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRankingStatInfo> {
        return NSFetchRequest<EventRankingStatInfo>(entityName: EventRankingStatInfo.entityName)
    }

    public var name: String {
        guard let name = nameString else {
            fatalError("Save EventRankingStatInfo before accessing name")
        }
        return name
    }

    public var precision: Int {
        guard let precision = precisionNumber?.intValue else {
            fatalError("Save EventRankingStatInfo before accessing precision")
        }
        return precision
    }

    @NSManaged private var nameString: String?
    @NSManaged private var precisionNumber: NSNumber?

    public var extraStatsRankings: [EventRanking] {
        guard let extraStatsRankingsMany = extraStatsRankingsMany, let extraStatsRankings = extraStatsRankingsMany.allObjects as? [EventRanking] else {
            return []
        }
        return extraStatsRankings
    }

    public var sortOrdersRankings: [EventRanking] {
        guard let sortOrdersRankingsMany = sortOrdersRankingsMany, let sortOrdersRankings = sortOrdersRankingsMany.allObjects as? [EventRanking] else {
            return []
        }
        return sortOrdersRankings
    }

    @NSManaged private var extraStatsRankingsMany: NSSet?
    @NSManaged private var sortOrdersRankingsMany: NSSet?

}

// MARK: Generated accessors for extraStatsRankingsMany
extension EventRankingStatInfo {

    @objc(removeExtraStatsRankingsManyObject:)
    @NSManaged internal func removeFromExtraStatsRankingsMany(_ value: EventRanking)

}

// MARK: Generated accessors for sortOrdersRankingsMany
extension EventRankingStatInfo {

    @objc(removeSortOrdersRankingsManyObject:)
    @NSManaged internal func removeFromSortOrdersRankingsMany(_ value: EventRanking)

}

extension EventRankingStatInfo: Managed {

    public static func insert(_ model: TBAEventRankingSortOrder, in context: NSManagedObjectContext) -> EventRankingStatInfo {
        let predicate = NSPredicate(format: "%K == %@ && %K == %ld",
                                    #keyPath(EventRankingStatInfo.nameString), model.name,
                                    #keyPath(EventRankingStatInfo.precisionNumber), model.precision)

        return findOrCreate(in: context, matching: predicate, configure: { (eventRankingStatInfo) in
            eventRankingStatInfo.nameString = model.name
            eventRankingStatInfo.precisionNumber = NSNumber(value: model.precision)
        })
    }

}

extension EventRankingStatInfo: Orphanable {

    public var isOrphaned: Bool {
        return sortOrdersRankings.count == 0 && extraStatsRankings.count == 0
    }

}
