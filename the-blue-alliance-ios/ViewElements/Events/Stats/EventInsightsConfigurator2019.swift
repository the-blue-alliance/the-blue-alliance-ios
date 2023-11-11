import Foundation
import UIKit

class EventInsightsConfigurator2019: EventInsightsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(highScoreRow(title: "High Score", key: "high_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Match Score", key: "average_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Winning Score", key: "average_win_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Win Margin", key: "average_win_margin", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Sandstorm Bonus Points", key: "average_sandstorm_bonus_auto", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Hatch Panel Points", key: "average_hatch_panel_points", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cargo Points", key: "average_cargo_points", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average HAB Climb Points", key: "average_hab_climb_teleop", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Foul Points", key: "average_foul_score", qual: qual, playoff: playoff))
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

        bonusStats.append(bonusRow(title: "Cross HAB Line", key: "cross_hab_line_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Cross HAB Line in Sandstorm", key: "cross_hab_line_sandstorm_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Complete 1 Rocket", key: "complete_1_rocket_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Complete 2 Rockets", key: "complete_2_rockets_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Complete Rocket RP", key: "rocket_rp_achieved", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Level 1 HAB Climb", key: "level1_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Level 2 HAB Climb", key: "level2_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Level 3 HAB Climb", key: "level3_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "HAB Docking RP", key: "climb_rp_achieved", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "\"Unicorn Matches\" (Win + Complete Rocket + HAB Docking)", key: "unicorn_matches", qual: qual, playoff: playoff))

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(bonusStats, toSection: "Bonus Stats (# successful / # opportunities)")
        }
    }

}

