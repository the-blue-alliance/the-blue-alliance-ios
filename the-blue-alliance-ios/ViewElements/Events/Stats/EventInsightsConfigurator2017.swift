import Foundation
import UIKit

class EventInsightsConfigurator2017: EventInsightsConfigurator {

    static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>,
        _ qual: [String: Any]?,
        _ playoff: [String: Any]?
    ) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(
            highScoreRow(
                title: "Highest Pressure (kPa)",
                key: "high_kpa",
                qual: qual,
                playoff: playoff
            )
        )
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
                title: "Average Mobility Points",
                key: ["average_mobility_points_auto", "", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Rotor Points",
                key: [
                    "average_rotor_points_auto", "average_rotor_points_teleop",
                    "average_rotor_points",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Fuel Points",
                key: [
                    "average_fuel_points_auto", "average_fuel_points_teleop", "average_fuel_points",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average High Goal",
                key: [
                    "average_high_goals_auto", "average_high_goals_teleop", "average_high_goals",
                ],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Low Goal",
                key: ["average_low_goals_auto", "average_low_goals_teleop", "average_low_goals"],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Takeoff (Climb) Points",
                key: ["", "average_takeoff_points_teleop", ""],
                qual: qual,
                playoff: playoff
            )
        )
        fourColumnMatchStats.append(
            fourColumnRow(
                title: "Average Foul Score",
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
            bonusRow(title: "Auto Mobility", key: "mobility_counts", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(
                title: "Teleop Takeoff (Climb)",
                key: "takeoff_counts",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Pressure Bonus (kPa Achieved)",
                key: "kpa_achieved",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Rotor 1 Engaged (Auto)",
                key: "rotor_1_engaged_auto",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(
                title: "Rotor 2 Engaged (Auto)",
                key: "rotor_2_engaged_auto",
                qual: qual,
                playoff: playoff
            )
        )
        bonusStats.append(
            bonusRow(title: "Rotor 1 Engaged", key: "rotor_1_engaged", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Rotor 2 Engaged", key: "rotor_2_engaged", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Rotor 3 Engaged", key: "rotor_3_engaged", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(title: "Rotor 4 Engaged", key: "rotor_4_engaged", qual: qual, playoff: playoff)
        )
        bonusStats.append(
            bonusRow(
                title: "\"Unicorn Matches\" (Win + kPa & Rotor Bonuses)",
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
