import Foundation
import UIKit

class EventInsightsConfigurator2024: EventInsightsConfigurator {

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
            bonusRow(title: "Melody RP", key: "melody_rp_count", qual: qual, playoff: nil)
        )
        bonusStats.append(
            bonusRow(title: "Ensemble RP", key: "ensemble_rp_count", qual: qual, playoff: nil)
        )
        bonusStats.append(
            bonusRow(title: "Coopertition", key: "coopertition_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(bonusRow(title: "4 RP", key: "four_rp_count", qual: qual, playoff: nil))
        bonusStats.append(bonusRow(title: "6 RP", key: "six_rp_count", qual: qual, playoff: nil))
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
