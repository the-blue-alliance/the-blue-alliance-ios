import Foundation
import CoreData
import TBAKit

extension EventRankingStatInfo: Managed {

    class func insert(_ model: TBAEventRankingSortOrder, in context: NSManagedObjectContext) -> EventRankingStatInfo {
        let predicate = NSPredicate(format: "%K == %@ && %K == %ld",
                                    #keyPath(EventRankingStatInfo.name), model.name,
                                    #keyPath(EventRankingStatInfo.precision), model.precision)

        return findOrCreate(in: context, matching: predicate, configure: { (eventRankingStatInfo) in
            eventRankingStatInfo.name = model.name
            eventRankingStatInfo.precision = Int16(model.precision)
        })
    }

    var isOrphaned: Bool {
        let hasSortOrders: Bool = {
            guard let sortOrdersRankings = sortOrdersRankings else {
                return false
            }
            return sortOrdersRankings.count > 0
        }()
        let hasExtraStats: Bool = {
            guard let extraStatsRankings = extraStatsRankings else {
                return false
            }
            return extraStatsRankings.count > 0
        }()
        return !hasSortOrders && !hasExtraStats
    }

}
