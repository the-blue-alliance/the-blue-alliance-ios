import Foundation
import UIKit

class EventStatsConfigurator2019: EventStatsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(InsightRow(title: "High Score", qual: highScoreString(qual, "high_score"), playoff: highScoreString(playoff, "high_score")))
        matchStats.append(InsightRow(title: "Average Match Score", qual: scoreFor(qual, "average_score"), playoff: scoreFor(playoff, "average_score")))
        matchStats.append(InsightRow(title: "Average Winning Score", qual: scoreFor(qual, "average_win_score"), playoff: scoreFor(playoff, "average_win_score")))
        matchStats.append(InsightRow(title: "Average Win Margin", qual: scoreFor(qual, "average_win_margin"), playoff: scoreFor(playoff, "average_win_margin")))
        matchStats.append(InsightRow(title: "Average Sandstorm Bonus Points", qual: scoreFor(qual, "average_sandstorm_bonus_auto"), playoff: scoreFor(playoff, "average_sandstorm_bonus_auto")))
        matchStats.append(InsightRow(title: "Average Hatch Panel Points", qual: scoreFor(qual, "average_hatch_panel_points"), playoff: scoreFor(playoff, "average_hatch_panel_points")))
        matchStats.append(InsightRow(title: "Average Cargo Points", qual: scoreFor(qual, "average_cargo_points"), playoff: scoreFor(playoff, "average_cargo_points")))
        matchStats.append(InsightRow(title: "Average HAB Climb Points", qual: scoreFor(qual, "average_hab_climb_teleop"), playoff: scoreFor(playoff, "average_hab_climb_teleop")))
        matchStats.append(InsightRow(title: "Average Foul Points", qual: scoreFor(qual, "average_foul_score"), playoff: scoreFor(playoff, "average_foul_score")))
        matchStats.append(InsightRow(title: "Average Score", qual: scoreFor(qual, "average_score"), playoff: scoreFor(playoff, "average_score")))

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        // Bonus Stats
        var bonusStats: [InsightRow] = []

        bonusStats.append(InsightRow(title: "Cross HAB Line", qual: bonusStat(qual, "cross_hab_line_count"), playoff: bonusStat(playoff, "cross_hab_line_count")))
        bonusStats.append(InsightRow(title: "Cross HAB Line in Sandstorm", qual: bonusStat(qual, "cross_hab_line_sandstorm_count"), playoff: bonusStat(playoff, "cross_hab_line_sandstorm_count")))
        bonusStats.append(InsightRow(title: "Complete 1 Rocket", qual: bonusStat(qual, "complete_1_rocket_count"), playoff: bonusStat(playoff, "complete_1_rocket_count")))
        bonusStats.append(InsightRow(title: "Complete 2 Rockets", qual: bonusStat(qual, "complete_2_rockets_count"), playoff: bonusStat(playoff, "complete_2_rockets_count")))
        bonusStats.append(InsightRow(title: "Complete Rocket RP", qual: bonusStat(qual, "rocket_rp_achieved"), playoff: bonusStat(playoff, "rocket_rp_achieved")))
        bonusStats.append(InsightRow(title: "Level 1 HAB Climb", qual: bonusStat(qual, "level1_climb_count"), playoff: bonusStat(playoff, "level1_climb_count")))
        bonusStats.append(InsightRow(title: "Level 2 HAB Climb", qual: bonusStat(qual, "level2_climb_count"), playoff: bonusStat(playoff, "level2_climb_count")))
        bonusStats.append(InsightRow(title: "Level 3 HAB Climb", qual: bonusStat(qual, "level3_climb_count"), playoff: bonusStat(playoff, "level3_climb_count")))
        bonusStats.append(InsightRow(title: "HAB Docking RP", qual: bonusStat(qual, "climb_rp_achieved"), playoff: bonusStat(playoff, "climb_rp_achieved")))
        bonusStats.append(InsightRow(title: "\"Unicorn Matches\" (Win + Complete Rocket + HAB Docking)", qual: bonusStat(qual, "unicorn_matches"), playoff: bonusStat(playoff, "unicorn_matches")))

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(bonusStats, toSection: "Bonus Stats (# successful / # opportunities)")
        }
    }

}

