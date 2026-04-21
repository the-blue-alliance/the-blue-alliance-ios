import Foundation
import UIKit

class EventInsightsConfigurator2023: EventInsightsConfigurator {

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
                key: "average_win_score",
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
            bonusRow(title: "Mobility", key: "mobility_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Auto Docked", key: "mobility_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Auto Engaged", key: "mobility_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(
                title: "Coopertition Criteria Met",
                key: "coopertition",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Sustainability Bonus RP",
                key: "sustainability_bonus_rp",
                qual: qual,
                playoff: nil
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Activation Bonus RP",
                key: "activation_bonus_rp",
                qual: qual,
                playoff: nil
            )
        )
        bonusStats.append(
            bonusRow(
                title: "\"Unicorn Matches\" (Win + Cargo Bonus + Hangar Bonus)",
                key: "unicorn_matches",
                qual: qual,
                playoff: nil
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
    }
}
