import Foundation
import TBAKit
import CoreData

extension EventRanking: Managed {

    var infoString: String? {
        get {
            if let tieBreakerValues = tieBreakerValues, !tieBreakerValues.isEmpty, let tieBreakerNames = tieBreakerNames, !tieBreakerNames.isEmpty {
                var infoParts: [String] = []
                for (sortOrderName, sortOrderValue) in zip(tieBreakerNames, tieBreakerValues) {
                    infoParts.append("\(sortOrderName): \(sortOrderValue)")
                }
                return infoParts.joined(separator: ", ")
            }
            return nil
        }
    }

    static func insert(with model: TBAEventRanking, for event: Event, for sortOrderInfo: [TBAEventRankingSortOrder], in context: NSManagedObjectContext) -> EventRanking {
        let teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
        let predicate = NSPredicate(format: "event == %@ AND teamKey == %@", event, teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.event = event
            ranking.teamKey = teamKey

            if let qualAverage = model.qualAverage {
                ranking.qualAverage = NSNumber(value: qualAverage)
            }

            ranking.rank = Int16(model.rank)

            if let record = model.record {
                ranking.record = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
            }

            if let dq = model.dq {
                ranking.dq = NSNumber(value: dq)
            }

            if let matchesPlayed = model.matchesPlayed {
                ranking.matchesPlayed = NSNumber(value: matchesPlayed)
            }

            if let extraStats = model.extraStats, !extraStats.isEmpty {
                ranking.extraStats = extraStats
            }

            if let tieBreakerValues = model.sortOrders, !tieBreakerValues.isEmpty {
                ranking.tieBreakerValues = tieBreakerValues
            }

            let tieBreakerNames = sortOrderInfo.map { $0.name }
            if !tieBreakerNames.isEmpty {
                ranking.tieBreakerNames = tieBreakerNames
            }
        })
    }

    var isOrphaned: Bool {
        // TODO: Fix when we audit
        return false
    }

}
