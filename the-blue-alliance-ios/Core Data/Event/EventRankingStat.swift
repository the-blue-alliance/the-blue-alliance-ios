import Foundation
import CoreData

extension EventRankingStat: Managed {

    static func insert(value: NSNumber, sortOrderRanking: EventRanking, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.value = value
        eventRankingStat.sortOrderRanking = sortOrderRanking
        return eventRankingStat
    }

    static func insert(value: NSNumber, extraStatsRanking: EventRanking, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.value = value
        eventRankingStat.extraStatsRanking = extraStatsRanking
        return eventRankingStat
    }

    private static func insert(value: NSNumber, sortOrderRanking: EventRanking?, extraStatsRanking: EventRanking?, in context: NSManagedObjectContext) -> EventRankingStat {
        let eventRankingStat = EventRankingStat.init(entity: entity(), insertInto: context)
        eventRankingStat.value = value
        eventRankingStat.sortOrderRanking = sortOrderRanking
        eventRankingStat.extraStatsRanking = extraStatsRanking
        return eventRankingStat
    }

    var isOrphaned: Bool {
        return sortOrderRanking == nil && extraStatsRanking == nil
    }

    public override func willSave() {
        super.willSave()

        // Do some additional validation, since we can't do an either-or or neither sort of validation in Core Data
        if sortOrderRanking != nil, extraStatsRanking != nil {
            fatalError("EventRankingStat must not have a relationship to both an extraStat and sortOrder")
        } else if sortOrderRanking == nil, extraStatsRanking == nil {
            fatalError("EventRankingStat must have a relationship to either an extraStat and sortOrder")
        }
    }

}
