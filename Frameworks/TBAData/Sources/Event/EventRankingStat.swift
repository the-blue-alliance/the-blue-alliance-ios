import CoreData
import Foundation

extension EventRankingStat {

    public var value: Double {
        guard let value = getValue(\EventRankingStat.valueRaw)?.doubleValue else {
            fatalError("Save EventRankingStat before accessing value")
        }
        return value
    }

    public var extraStatsRanking: EventRanking? {
        return getValue(\EventRankingStat.extraStatsRankingRaw)
    }

    public var sortOrderRanking: EventRanking? {
        return getValue(\EventRankingStat.sortOrderRankingRaw)
    }

}

@objc(EventRankingStat)
public class EventRankingStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRankingStat> {
        return NSFetchRequest<EventRankingStat>(entityName: EventRankingStat.entityName)
    }

    @NSManaged var valueRaw: NSNumber?
    @NSManaged var extraStatsRankingRaw: EventRanking?
    @NSManaged var sortOrderRankingRaw: EventRanking?

}

extension EventRankingStat: Managed {

    internal static func insert(value: Double, sortOrderRanking: EventRanking, in context: NSManagedObjectContext) -> EventRankingStat {
        return insert(value: value, sortOrderRanking: sortOrderRanking, extraStatsRanking: nil, in: context)
    }

    internal static func insert(value: Double, extraStatsRanking: EventRanking, in context: NSManagedObjectContext) -> EventRankingStat {
        return insert(value: value, sortOrderRanking: nil, extraStatsRanking: extraStatsRanking, in: context)
    }

    internal static func insert(value: Double, sortOrderRanking: EventRanking?, extraStatsRanking: EventRanking?, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.valueRaw = NSNumber(value: value)
        eventRankingStat.sortOrderRankingRaw = sortOrderRanking
        eventRankingStat.extraStatsRankingRaw = extraStatsRanking
        return eventRankingStat
    }

    public override func willSave() {
        super.willSave()

        // If we're being delted - don't bother validating
        if isDeleted {
            return
        }

        // Do some additional validation, since we can't do an either-or or neither sort of validation in Core Data
        if sortOrderRankingRaw != nil, extraStatsRankingRaw != nil {
            fatalError("EventRankingStat must not have a relationship to both an extraStat and sortOrder")
        } else if sortOrderRankingRaw == nil, extraStatsRankingRaw == nil {
            fatalError("EventRankingStat must have a relationship to either an extraStat and sortOrder")
        }
    }

}

extension EventRankingStat: Orphanable {

    public var isOrphaned: Bool {
        return sortOrderRankingRaw == nil && extraStatsRankingRaw == nil
    }

}
