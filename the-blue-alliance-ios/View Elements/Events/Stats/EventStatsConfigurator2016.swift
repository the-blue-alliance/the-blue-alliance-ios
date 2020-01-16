import Foundation
import UIKit

class EventStatsConfigurator2016: EventStatsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(InsightRow(title: "High Score", qual: highScoreString(qual, "high_score"), playoff: highScoreString(playoff, "high_score")))
        matchStats.append(InsightRow(title: "Average Low Goal", qual: scoreFor(qual, "average_low_goals"), playoff: scoreFor(playoff, "average_low_goals")))
        matchStats.append(InsightRow(title: "Average High Goal", qual: scoreFor(qual, "average_high_goals"), playoff: scoreFor(playoff, "average_high_goals")))
        matchStats.append(InsightRow(title: "Average Match Score", qual: scoreFor(qual, "average_score"), playoff: scoreFor(playoff, "average_score")))
        matchStats.append(InsightRow(title: "Average Winning Score", qual: scoreFor(qual, "average_win_score"), playoff: scoreFor(playoff, "average_win_score")))
        matchStats.append(InsightRow(title: "Average Win Margin", qual: scoreFor(qual, "average_win_margin"), playoff: scoreFor(playoff, "average_win_margin")))
        matchStats.append(InsightRow(title: "Average Auto Score", qual: scoreFor(qual, "average_auto_score"), playoff: scoreFor(playoff, "average_auto_score")))
        matchStats.append(InsightRow(title: "Average Teleop Crossing Score", qual: scoreFor(qual, "average_crossing_score"), playoff: scoreFor(playoff, "average_crossing_score")))
        matchStats.append(InsightRow(title: "Average Teleop Boulder Score", qual: scoreFor(qual, "average_boulder_score"), playoff: scoreFor(playoff, "average_boulder_score")))
        matchStats.append(InsightRow(title: "Average Teleop Tower Score", qual: scoreFor(qual, "average_tower_score"), playoff: scoreFor(playoff, "average_tower_score")))
        matchStats.append(InsightRow(title: "Average Foul Score", qual: scoreFor(qual, "average_foul_score"), playoff: scoreFor(playoff, "average_foul_score")))

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        // Tower Stats
        var towerStats: [InsightRow] = []

        towerStats.append(InsightRow(title: "Challenges", qual: bonusStat(qual, "challenges"), playoff: bonusStat(playoff, "challenges")))
        towerStats.append(InsightRow(title: "Scales", qual: bonusStat(qual, "scales"), playoff: bonusStat(playoff, "scales")))
        towerStats.append(InsightRow(title: "Captures", qual: bonusStat(qual, "captures"), playoff: bonusStat(playoff, "captures")))

        towerStats = filterEmptyInsights(towerStats)
        if !towerStats.isEmpty {
            snapshot.appendSections(["Tower Stats (# successful / # opportunities)"])
            snapshot.appendItems(towerStats, toSection: "Tower Stats (# successful / # opportunities)")
        }

        // Defense Stats
        var defenseStats: [InsightRow] = []

        defenseStats.append(InsightRow(title: "Low Bar", qual: bonusStat(qual, "LowBar"), playoff: bonusStat(playoff, "LowBar")))
        defenseStats.append(InsightRow(title: "Cheval De Frise", qual: bonusStat(qual, "A_ChevalDeFrise"), playoff: bonusStat(playoff, "A_ChevalDeFrise")))
        defenseStats.append(InsightRow(title: "Portcullis", qual: bonusStat(qual, "A_Portcullis"), playoff: bonusStat(playoff, "A_Portcullis")))
        defenseStats.append(InsightRow(title: "Ramparts", qual: bonusStat(qual, "B_Ramparts"), playoff: bonusStat(playoff, "B_Ramparts")))
        defenseStats.append(InsightRow(title: "Moat", qual: bonusStat(qual, "B_Moat"), playoff: bonusStat(playoff, "B_Moat")))
        defenseStats.append(InsightRow(title: "Sally Port", qual: bonusStat(qual, "C_SallyPort"), playoff: bonusStat(playoff, "C_SallyPort")))
        defenseStats.append(InsightRow(title: "Drawbridge", qual: bonusStat(qual, "C_Drawbridge"), playoff: bonusStat(playoff, "C_Drawbridge")))
        defenseStats.append(InsightRow(title: "Rough Terrain", qual: bonusStat(qual, "D_RoughTerrain"), playoff: bonusStat(playoff, "D_RoughTerrain")))
        defenseStats.append(InsightRow(title: "Rock Wall", qual: bonusStat(qual, "D_RockWall"), playoff: bonusStat(playoff, "D_RockWall")))
        defenseStats.append(InsightRow(title: "Total Breaches", qual: bonusStat(qual, "breaches"), playoff: bonusStat(playoff, "breaches")))

        defenseStats = filterEmptyInsights(defenseStats)
        if !defenseStats.isEmpty {
            snapshot.appendSections(["Defense Stats (# damaged / # opportunities)"])
            snapshot.appendItems(defenseStats, toSection: "Defense Stats (# damaged / # opportunities)")
        }

    }

}
