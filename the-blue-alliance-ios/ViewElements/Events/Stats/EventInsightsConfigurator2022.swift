import Foundation
import UIKit

class EventInsightsConfigurator2022: EventInsightsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(highScoreRow(title: "High Score", key: "high_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Match Score", key: "average_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Winning Score", key: "average_win_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Win Margin", key: "average_win_margin", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Taxi Points", key: "average_taxi_points", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cargo Count (Lower)", key: "average_lower_cargo_count", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cargo Count (Upper)", key: "average_upper_cargo_count", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cargo Count", key: "average_cargo_count", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Cargo Points", key: "average_cargo_points", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Hangar Points", key: "average_endgame_points", qual: qual, playoff: playoff))
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

        bonusStats.append(bonusRow(title: "Taxi", key: "taxi_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Quintet Achieved", key: "quintet_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Low Climb", key: "low_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Mid Climb", key: "mid_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "High Climb", key: "high_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Traversal Climb", key: "traversal_climb_count", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Cargo Bonus RP Achieved", key: "cargo_bonus_rp", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "Hangar Bonus RP Achieved", key: "hangar_bonus_rp", qual: qual, playoff: playoff))
        bonusStats.append(bonusRow(title: "\"Unicorn Matches\" (Win + Cargo Bonus + Hangar Bonus)", key: "unicorn_matches", qual: qual, playoff: playoff))

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(bonusStats, toSection: "Bonus Stats (# successful / # opportunities)")
        }
    }

}
