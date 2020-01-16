import Foundation
import UIKit

class EventStatsConfigurator2017: EventStatsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(InsightRow(title: "Highest Pressure (kPa)", qual: highScoreString(qual, "high_kpa"), playoff: highScoreString(playoff, "high_kpa")))
        matchStats.append(InsightRow(title: "High Score", qual: highScoreString(qual, "high_score"), playoff: highScoreString(playoff, "high_score")))
        matchStats.append(InsightRow(title: "Average Match Score", qual: scoreFor(qual, "average_score"), playoff: scoreFor(playoff, "average_score")))
        matchStats.append(InsightRow(title: "Average Winning Score", qual: scoreFor(qual, "average_win_score"), playoff: scoreFor(playoff, "average_win_score")))
        matchStats.append(InsightRow(title: "Average Win Margin", qual: scoreFor(qual, "average_win_margin"), playoff: scoreFor(playoff, "average_win_margin")))
        matchStats.append(InsightRow(title: "Average Mobility Points", qual: scoreFor(qual, "average_mobility_points_auto"), playoff: scoreFor(playoff, "average_mobility_points_auto")))
        matchStats.append(InsightRow(title: "Average Rotor Points", qual: scoreFor(qual, "average_rotor_points"), playoff: scoreFor(playoff, "average_rotor_points")))
        matchStats.append(InsightRow(title: "Average Fuel Points", qual: scoreFor(qual, "average_fuel_points"), playoff: scoreFor(playoff, "average_fuel_points")))
        matchStats.append(InsightRow(title: "Average High Goal", qual: scoreFor(qual, "average_high_goals"), playoff: scoreFor(playoff, "average_high_goals")))
        matchStats.append(InsightRow(title: "Average Low Goal", qual: scoreFor(qual, "average_low_goals"), playoff: scoreFor(playoff, "average_low_goals")))
        matchStats.append(InsightRow(title: "Average Takeoff (Climb) Points", qual: scoreFor(qual, "average_takeoff_points_teleop"), playoff: scoreFor(playoff, "average_takeoff_points_teleop")))
        matchStats.append(InsightRow(title: "Average Foul Score", qual: scoreFor(qual, "average_foul_score"), playoff: scoreFor(playoff, "average_foul_score")))

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        // Bonus Stats
        var bonusStats: [InsightRow] = []

        bonusStats.append(InsightRow(title: "Auto Mobility", qual: bonusStat(qual, "mobility_counts"), playoff: bonusStat(playoff, "mobility_counts")))
        bonusStats.append(InsightRow(title: "Teleop Takeoff (Climb)", qual: bonusStat(qual, "takeoff_counts"), playoff: bonusStat(playoff, "takeoff_counts")))
        bonusStats.append(InsightRow(title: "Pressure Bonus (kPa Achieved)", qual: bonusStat(qual, "kpa_achieved"), playoff: bonusStat(playoff, "kpa_achieved")))
        bonusStats.append(InsightRow(title: "Rotor 1 Engaged (Auto)", qual: bonusStat(qual, "rotor_1_engaged_auto"), playoff: bonusStat(playoff, "rotor_1_engaged_auto")))
        bonusStats.append(InsightRow(title: "Rotor 2 Engaged (Auto)", qual: bonusStat(qual, "rotor_2_engaged_auto"), playoff: bonusStat(playoff, "rotor_2_engaged_auto")))
        bonusStats.append(InsightRow(title: "Rotor 1 Engaged", qual: bonusStat(qual, "rotor_1_engaged"), playoff: bonusStat(playoff, "rotor_1_engaged")))
        bonusStats.append(InsightRow(title: "Rotor 2 Engaged", qual: bonusStat(qual, "rotor_2_engaged"), playoff: bonusStat(playoff, "rotor_2_engaged")))
        bonusStats.append(InsightRow(title: "Rotor 3 Engaged", qual: bonusStat(qual, "rotor_3_engaged"), playoff: bonusStat(playoff, "rotor_3_engaged")))
        bonusStats.append(InsightRow(title: "Rotor 4 Engaged", qual: bonusStat(qual, "rotor_4_engaged"), playoff: bonusStat(playoff, "rotor_4_engaged")))
        bonusStats.append(InsightRow(title: "\"Unicorn Matches\" (Win + kPa & Rotor Bonuses)", qual: bonusStat(qual, "unicorn_matches"), playoff: bonusStat(playoff, "unicorn_matches")))

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(bonusStats, toSection: "Bonus Stats (# successful / # opportunities)")
        }
    }

}
