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
        var fourColumnMatchStats: [InsightRow] = []

        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Mobility Points",
                key: ["average_mobility_points", "", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Game Piece Points",
                key: ["average_piece_points_auto", "average_piece_points_teleop", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Park Points",
                key: ["", "average_park_points", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Charge Station Points",
                key: [
                    "average_charge_station_points_auto", "average_charge_station_points_teleop",
                    "",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Link Points",
                key: ["", "", "average_link_points"],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Foul Points",
                key: ["", "", "average_foul_score"],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Score",
                key: ["average_points_auto", "average_points_teleop", "average_score"],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats = filterEmptyInsights(fourColumnMatchStats)
        if !fourColumnMatchStats.isEmpty {
            snapshot.appendSections(["Match Stats (Auto / Teleop / Overall)"])
            snapshot.appendItems(
                fourColumnMatchStats,
                toSection: "Match Stats (Auto / Teleop / Overall)"
            )
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
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Activation Bonus RP",
                key: "activation_bonus_rp",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "\"Unicorn Matches\" (Win + Cargo Bonus + Hangar Bonus)",
                key: "unicorn_matches",
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
    }
}
