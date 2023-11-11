import Foundation
import UIKit

class EventInsightsConfigurator2020: EventInsightsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(highScoreRow(title: "High Score", key: "high_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Match Score", key: "average_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Winning Score", key: "average_win_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Win Margin", key: "average_win_margin", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Initiation Line Points", key: "average_init_line_points_auto", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cell Count (Bottom)", key: "average_cell_count_bottom", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cell Count (Outer)", key: "average_cell_count_outer", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cell Count (Inner)", key: "average_cell_count_inner", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cell Count", key: "average_cell_count", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cell Points", key: "average_cell_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Control Panel Points", key: "average_control_panel_points", qual: qual, playoff: playoff))
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

        bonusStats.append(bonusRow(title: "Exit Initiation Line", key: "exit_init_line_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Achieve Stage 1", key: "achieve_stage1_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Achieve Stage 2", key: "achieve_stage2_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Achieve Stage 3", key: "achieve_stage3_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Endgame Parking", key: "park_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Endgame Hanging", key: "hang_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Generator Level + Hang", key: "generator_level_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Shield Generator Operational RP Achieved", key: "generator_operational_rp_achieved", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Shield Generator Energized RP Achieved", key: "generator_energized_rp_achieved", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "\"Unicorn Matches\" (Win + Generator Operational + Generator Energized)", key: "unicorn_matches", qual: qual, playoff: playoff))

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(bonusStats, toSection: "Bonus Stats (# successful / # opportunities)")
        }
    }

}
