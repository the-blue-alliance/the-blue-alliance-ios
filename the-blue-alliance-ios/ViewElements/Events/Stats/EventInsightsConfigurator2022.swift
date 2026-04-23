import Foundation
import UIKit

class EventInsightsConfigurator2022: EventInsightsConfigurator {

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

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        var fourColumnMatchStats: [InsightRow] = []

        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Taxi Points",
                key: ["average_taxi_points", "", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Cargo Count (Lower)",
                key: [
                    "average_lower_cargo_count_auto", "average_lower_cargo_count_teleop",
                    "average_lower_cargo_count",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Cargo Count (Upper)",
                key: [
                    "average_upper_cargo_count_auto", "average_upper_cargo_count_teleop",
                    "average_upper_cargo_count",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Cargo Count",
                key: [
                    "average_cargo_count_auto", "average_cargo_count_teleop", "average_cargo_count",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Cargo Points",
                key: [
                    "average_cargo_points_auto", "average_cargo_points_teleop",
                    "average_cargo_points",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Hangar Points",
                key: ["", "average_endgame_points", ""],
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

        bonusStats.append(bonusRow(title: "Taxi", key: "taxi_count", qual: qual, playoff: playoff))
        bonusStats.append(
            bonusRow(title: "Quintet Achieved", key: "quintet_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Low Climb", key: "low_climb_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Mid Climb", key: "mid_climb_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "High Climb", key: "high_climb_count", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(
                title: "Traversal Climb",
                key: "traversal_climb_count",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Cargo Bonus RP Achieved",
                key: "cargo_bonus_rp",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Hangar Bonus RP Achieved",
                key: "hangar_bonus_rp",
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
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(
                bonusStats,
                toSection: "Bonus Stats (# successful / # opportunities)"
            )
        }
    }

}
