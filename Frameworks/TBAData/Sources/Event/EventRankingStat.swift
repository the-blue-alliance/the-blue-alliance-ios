import CoreData
import Foundation

@objc(EventRankingStat)
public class EventRankingStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRankingStat> {
        return NSFetchRequest<EventRankingStat>(entityName: "EventRankingStat")
    }

    @NSManaged public fileprivate(set) var value: Double
    @NSManaged public fileprivate(set) var extraStatsRanking: EventRanking?
    @NSManaged public fileprivate(set) var sortOrderRanking: EventRanking?

}

extension EventRankingStat {

    internal static func insert(value: Double, sortOrderRanking: EventRanking, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.value = value
        eventRankingStat.sortOrderRanking = sortOrderRanking
        return eventRankingStat
    }

    internal static func insert(value: Double, extraStatsRanking: EventRanking, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.value = value
        eventRankingStat.extraStatsRanking = extraStatsRanking
        return eventRankingStat
    }

    internal static func insert(value: Double, sortOrderRanking: EventRanking?, extraStatsRanking: EventRanking?, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.value = value
        eventRankingStat.sortOrderRanking = sortOrderRanking
        eventRankingStat.extraStatsRanking = extraStatsRanking
        return eventRankingStat
    }

    public override func willSave() {
        super.willSave()

        // If we're being delted - don't bother validating
        if isDeleted {
            return
        }

        // Do some additional validation, since we can't do an either-or or neither sort of validation in Core Data
        if sortOrderRanking != nil, extraStatsRanking != nil {
            fatalError("EventRankingStat must not have a relationship to both an extraStat and sortOrder")
        } else if sortOrderRanking == nil, extraStatsRanking == nil {
            fatalError("EventRankingStat must have a relationship to either an extraStat and sortOrder")
        }
    }

}

extension EventRankingStat: Managed {

    public var isOrphaned: Bool {
        return sortOrderRanking == nil && extraStatsRanking == nil
    }

}
