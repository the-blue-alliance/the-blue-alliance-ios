import Foundation
import UIKit

class EventInsightsConfigurator2026: EventInsightsConfigurator {

    static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>,
        _ qual: [String: Any]?,
        _ playoff: [String: Any]?
    ) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(
            highScoreRow(title: "High Score", key: "high_score", qual: qual, playoff: playoff)
        )
        matchStats.append(
            scoreRow(
                title: "Average Match Score",
                key: "average_score",
                qual: qual,
                playoff: playoff
            )
        )
        matchStats.append(
            scoreRow(
                title: "Average Winning Score",
                key: "average_winning_score",
                qual: qual,
                playoff: playoff
            )
        )
        matchStats.append(
            scoreRow(
                title: "Average Win Margin",
                key: "average_win_margin",
                qual: qual,
                playoff: playoff
            )
        )
        // Note - this is not helpful, since we already show "Average Match Score"
        // If we can show breakdowns by Auto/Teleop/Overall like on web, we can add this back
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/744
        // matchStats.append(scoreRow(title: "Average Score", key: "average_score", qual: qual, playoff: playoff))

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        // Bonus Stats
        var bonusStats: [InsightRow] = []

        bonusStats.append(
            bonusRow(title: "Energized RP", key: "energized_rp_count", qual: qual, playoff: nil)
        )
        bonusStats.append(
            bonusRow(
                title: "Supercharged RP",
                key: "supercharged_rp_count",
                qual: qual,
                playoff: nil
            )
        )
        bonusStats.append(
            bonusRow(title: "Traversal RP", key: "traversal_rp_count", qual: qual, playoff: nil)
        )
        bonusStats.append(bonusRow(title: "6 RP", key: "six_rp_count", qual: qual, playoff: nil))
        bonusStats.append(bonusRow(title: "9 RP", key: "nine_rp_count", qual: qual, playoff: nil))
        bonusStats.append(
            bonusRow(
                title: "Auto Win Conversion",
                key: "auto_win_conversion",
                qual: qual,
                playoff: playoff
            )
        )

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (Count / Opportunities / Success)"])
            snapshot.appendItems(
                bonusStats,
                toSection: "Bonus Stats (Count / Opportunities / Success)"
            )
        }

        var fuelStats: [InsightRow] = []

        fuelStats.append(
            totalsRow(
                title: "Auto Fuel Scored",
                key: "auto_fuel_scored",
                qual: qual,
                playoff: playoff
            )
        )
        fuelStats.append(
            totalsRow(
                title: "Teleop Fuel Scored",
                key: "teleop_fuel_scored",
                qual: qual,
                playoff: playoff
            )
        )
        fuelStats.append(
            totalsRow(
                title: "Total Fuel Scored",
                key: "total_fuel_scored",
                qual: qual,
                playoff: playoff
            )
        )

        fuelStats = filterEmptyInsights(fuelStats)
        if !fuelStats.isEmpty {
            snapshot.appendSections(["Fuel Stats (Count / Alliance / Team)"])
            snapshot.appendItems(fuelStats, toSection: "Fuel Stats (Count / Alliance / Team)")
        }

        var towerStats: [InsightRow] = []

        towerStats.append(
            bonusRow(title: "Auto Climb", key: "auto_climb_count", qual: qual, playoff: playoff)
        )
        towerStats.append(
            bonusRow(
                title: "Level 1 Climb",
                key: "level1_climb_count",
                qual: qual,
                playoff: playoff
            )
        )
        towerStats.append(
            bonusRow(
                title: "Level 2 Climb",
                key: "level2_climb_count",
                qual: qual,
                playoff: playoff
            )
        )
        towerStats.append(
            bonusRow(
                title: "Level 3 Climb",
                key: "level3_climb_count",
                qual: qual,
                playoff: playoff
            )
        )

        towerStats = filterEmptyInsights(towerStats)
        if !towerStats.isEmpty {
            snapshot.appendSections(["Tower Stats (Count / Opportunities / Success)"])
            snapshot.appendItems(
                towerStats,
                toSection: "Tower Stats (Count / Opportunities / Success)"
            )
        }

    }
}
