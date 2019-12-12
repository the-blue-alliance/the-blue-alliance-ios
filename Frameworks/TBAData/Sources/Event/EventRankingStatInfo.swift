import Foundation
import CoreData
import TBAKit

@objc(EventRankingStatInfo)
public class EventRankingStatInfo: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRankingStatInfo> {
        return NSFetchRequest<EventRankingStatInfo>(entityName: "EventRankingStatInfo")
    }

    @NSManaged public fileprivate(set) var name: String
    @NSManaged public fileprivate(set) var precision: Int16
    @NSManaged public fileprivate(set) var extraStatsRankings: NSSet
    @NSManaged public fileprivate(set) var sortOrdersRankings: NSSet

}

// MARK: Generated accessors for extraStatsRankings
extension EventRankingStatInfo {

    @objc(addExtraStatsRankingsObject:)
    @NSManaged internal func addToExtraStatsRankings(_ value: EventRanking)

    @objc(removeExtraStatsRankingsObject:)
    @NSManaged internal func removeFromExtraStatsRankings(_ value: EventRanking)

    @objc(addExtraStatsRankings:)
    @NSManaged internal func addToExtraStatsRankings(_ values: NSSet)

    @objc(removeExtraStatsRankings:)
    @NSManaged internal func removeFromExtraStatsRankings(_ values: NSSet)

}

// MARK: Generated accessors for sortOrdersRankings
extension EventRankingStatInfo {

    @objc(addSortOrdersRankingsObject:)
    @NSManaged internal func addToSortOrdersRankings(_ value: EventRanking)

    @objc(removeSortOrdersRankingsObject:)
    @NSManaged internal func removeFromSortOrdersRankings(_ value: EventRanking)

    @objc(addSortOrdersRankings:)
    @NSManaged internal func addToSortOrdersRankings(_ values: NSSet)

    @objc(removeSortOrdersRankings:)
    @NSManaged internal func removeFromSortOrdersRankings(_ values: NSSet)

}

extension EventRankingStatInfo {

    public static func insert(_ model: TBAEventRankingSortOrder, in context: NSManagedObjectContext) -> EventRankingStatInfo {
        let predicate = NSPredicate(format: "%K == %@ && %K == %ld",
                                    #keyPath(EventRankingStatInfo.name), model.name,
                                    #keyPath(EventRankingStatInfo.precision), model.precision)

        return findOrCreate(in: context, matching: predicate, configure: { (eventRankingStatInfo) in
            eventRankingStatInfo.name = model.name
            eventRankingStatInfo.precision = Int16(model.precision)
        })
    }

}

extension EventRankingStatInfo: Managed {

    public var isOrphaned: Bool {
        return sortOrdersRankings.count == 0 && extraStatsRankings.count == 0
    }

}
