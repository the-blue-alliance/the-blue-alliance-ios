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

    @discardableResult
    static func insert(with model: TBAEventRanking, for event: Event, for team: Team, for sortOrderInfo: [TBAEventRankingSortOrder], in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "event == %@ AND team == %@", event, team)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.event = event
            ranking.team = team

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
}
