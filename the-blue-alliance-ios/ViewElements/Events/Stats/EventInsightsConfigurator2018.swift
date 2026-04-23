import Foundation
import UIKit

class EventInsightsConfigurator2018: EventInsightsConfigurator {

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
                title: "Average Auto Run Points",
                key: ["average_run_points_auto", "", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Scale Ownership Points",
                key: [
                    "average_scale_ownership_points_auto", "average_scale_ownership_points_teleop",
                    "average_scale_ownership_points",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Switch Ownership Points",
                key: [
                    "average_switch_ownership_points_auto",
                    "average_switch_ownership_points_teleop", "average_switch_ownership_points",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Scale Neutral %",
                key: [
                    "scale_neutral_percentage_auto", "scale_neutral_percentage_teleop",
                    "scale_neutral_percentage",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Winner Scale Ownership %",
                key: [
                    "winning_scale_ownership_percentage_auto",
                    "winning_scale_ownership_percentage_teleop",
                    "winning_scale_ownership_percentage",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Winner Switch Ownership %",
                key: [
                    "winning_own_switch_ownership_percentage_auto",
                    "winning_own_switch_ownership_percentage_teleop",
                    "winning_own_switch_ownership_percentage",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Winner Opponent Switch Denial %",
                key: ["", "winning_opp_switch_denial_percentage_teleop", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average # Force Played",
                key: ["", "average_force_played", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average # Boost Played",
                key: ["", "average_boost_played", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Vault Points",
                key: ["", "average_vault_points", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Endgame Points",
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

        bonusStats.append(
            bonusRow(title: "Auto Run", key: "run_counts_auto", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(
                title: "Auto Switch Owned",
                key: "switch_owned_counts_auto",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(title: "Auto Quest", key: "auto_quest_achieved", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(
                title: "Force Played",
                key: "force_played_counts",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Levitate Played",
                key: "levitate_played_counts",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Boost Played",
                key: "boost_played_counts",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Climbs (does not include Levitate)",
                key: "climb_counts",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Face the Boss",
                key: "face_the_boss_achieved",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "\"Unicorn Matches\" (Win + Auto Quest + Face the Boss)",
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
