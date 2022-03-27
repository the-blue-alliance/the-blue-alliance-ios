import Foundation
import UIKit

class EventInsightsConfigurator2016: EventInsightsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(highScoreRow(title: "High Score", key: "high_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Low Goal", key: "average_low_goals", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average High Goal", key: "average_high_goals", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Match Score", key: "average_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Winning Score", key: "average_win_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Win Margin", key: "average_win_margin", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Auto Score", key: "average_auto_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Teleop Crossing Score", key: "average_crossing_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Teleop Boulder Score", key: "average_boulder_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Teleop Tower Score", key: "average_tower_score", qual: qual, playoff: playoff))
        matchStats.append(scoreRow(title: "Average Foul Score", key: "average_foul_score", qual: qual, playoff: playoff))

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        // Tower Stats
        var towerStats: [InsightRow] = []

        towerStats.append(bonusRow(title: "Challenges", key: "challenges", qual: qual, playoff: playoff))
        towerStats.append(bonusRow(title: "Scales", key: "scales", qual: qual, playoff: playoff))
        towerStats.append(bonusRow(title: "Captures", key: "captures", qual: qual, playoff: playoff))

        towerStats = filterEmptyInsights(towerStats)
        if !towerStats.isEmpty {
            snapshot.appendSections(["Tower Stats (# successful / # opportunities)"])
            snapshot.appendItems(towerStats, toSection: "Tower Stats (# successful / # opportunities)")
        }

        // Defense Stats
        var defenseStats: [InsightRow] = []

        defenseStats.append(bonusRow(title: "Low Bar", key: "LowBar", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Cheval De Frise", key: "A_ChevalDeFrise", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Portcullis", key: "A_Portcullis", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Ramparts", key: "B_Ramparts", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Moat", key: "B_Moat", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Sally Port", key: "C_SallyPort", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Drawbridge", key: "C_Drawbridge", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Rough Terrain", key: "D_RoughTerrain", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Rock Wall", key: "D_RockWall", qual: qual, playoff: playoff))
        defenseStats.append(bonusRow(title: "Total Breaches", key: "breaches", qual: qual, playoff: playoff))

        defenseStats = filterEmptyInsights(defenseStats)
        if !defenseStats.isEmpty {
            snapshot.appendSections(["Defense Stats (# damaged / # opportunities)"])
            snapshot.appendItems(defenseStats, toSection: "Defense Stats (# damaged / # opportunities)")
        }

    }

}
