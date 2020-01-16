import Foundation
import UIKit

class EventStatsConfigurator2018: EventStatsConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String : Any]?, _ playoff: [String : Any]?) {
        // Match Stats
        var matchStats: [InsightRow] = []

        matchStats.append(InsightRow(title: "High Score", qual: highScoreString(qual, "high_score"), playoff: highScoreString(playoff, "high_score")))
        matchStats.append(InsightRow(title: "Average Match Score", qual: scoreFor(qual, "average_score"), playoff: scoreFor(playoff, "average_score")))
        matchStats.append(InsightRow(title: "Average Winning Score", qual: scoreFor(qual, "average_win_score"), playoff: scoreFor(playoff, "average_win_score")))
        matchStats.append(InsightRow(title: "Average Win Margin", qual: scoreFor(qual, "average_win_margin"), playoff: scoreFor(playoff, "average_win_margin")))
        matchStats.append(InsightRow(title: "Average Auto Run Points", qual: scoreFor(qual, "average_run_points_auto"), playoff: scoreFor(playoff, "average_run_points_auto")))
        matchStats.append(InsightRow(title: "Average Scale Ownership Points", qual: scoreFor(qual, "average_scale_ownership_points"), playoff: scoreFor(playoff, "average_scale_ownership_points")))
        matchStats.append(InsightRow(title: "Average Switch Ownership Points", qual: scoreFor(qual, "average_switch_ownership_points"), playoff: scoreFor(playoff, "average_switch_ownership_points")))
        matchStats.append(InsightRow(title: "Scale Neutral %", qual: scoreFor(qual, "scale_neutral_percentage"), playoff: scoreFor(playoff, "scale_neutral_percentage")))
        matchStats.append(InsightRow(title: "Winner Scale Ownership %", qual: scoreFor(qual, "winning_scale_ownership_percentage"), playoff: scoreFor(playoff, "winning_scale_ownership_percentage")))
        matchStats.append(InsightRow(title: "Winner Switch Ownership %", qual: scoreFor(qual, "winning_own_switch_ownership_percentage"), playoff: scoreFor(playoff, "winning_own_switch_ownership_percentage")))
        matchStats.append(InsightRow(title: "Winner Opponent Switch Denial %", qual: scoreFor(qual, "winning_opp_switch_denial_percentage_teleop"), playoff: scoreFor(playoff, "winning_opp_switch_denial_percentage_teleop")))
        matchStats.append(InsightRow(title: "Average # Force Played", qual: scoreFor(qual, "average_force_played"), playoff: scoreFor(playoff, "average_force_played")))
        matchStats.append(InsightRow(title: "Average # Boost Played", qual: scoreFor(qual, "average_boost_played"), playoff: scoreFor(playoff, "average_boost_played")))
        matchStats.append(InsightRow(title: "Average Vault Points", qual: scoreFor(qual, "average_vault_points"), playoff: scoreFor(playoff, "average_vault_points")))
        matchStats.append(InsightRow(title: "Average Endgame Points", qual: scoreFor(qual, "average_endgame_points"), playoff: scoreFor(playoff, "average_endgame_points")))
        matchStats.append(InsightRow(title: "Average Foul Points", qual: scoreFor(qual, "average_foul_score"), playoff: scoreFor(playoff, "average_foul_score")))
        matchStats.append(InsightRow(title: "Average Score", qual: scoreFor(qual, "average_score"), playoff: scoreFor(playoff, "average_score")))

        matchStats = filterEmptyInsights(matchStats)
        if !matchStats.isEmpty {
            snapshot.appendSections(["Match Stats"])
            snapshot.appendItems(matchStats, toSection: "Match Stats")
        }

        // Bonus Stats
        var bonusStats: [InsightRow] = []

        bonusStats.append(InsightRow(title: "Auto Run", qual: bonusStat(qual, "run_counts_auto"), playoff: bonusStat(playoff, "run_counts_auto")))
        bonusStats.append(InsightRow(title: "Auto Switch Owned", qual: bonusStat(qual, "switch_owned_counts_auto"), playoff: bonusStat(playoff, "switch_owned_counts_auto")))
        bonusStats.append(InsightRow(title: "Auto Quest", qual: bonusStat(qual, "auto_quest_achieved"), playoff: bonusStat(playoff, "auto_quest_achieved")))
        bonusStats.append(InsightRow(title: "Force Played", qual: bonusStat(qual, "force_played_counts"), playoff: bonusStat(playoff, "force_played_counts")))
        bonusStats.append(InsightRow(title: "Levitate Played", qual: bonusStat(qual, "levitate_played_counts"), playoff: bonusStat(playoff, "levitate_played_counts")))
        bonusStats.append(InsightRow(title: "Boost Played", qual: bonusStat(qual, "boost_played_counts"), playoff: bonusStat(playoff, "boost_played_counts")))
        bonusStats.append(InsightRow(title: "Climbs (does not include Levitate)", qual: bonusStat(qual, "climb_counts"), playoff: bonusStat(playoff, "climb_counts")))
        bonusStats.append(InsightRow(title: "Face the Boss", qual: bonusStat(qual, "face_the_boss_achieved"), playoff: bonusStat(playoff, "face_the_boss_achieved")))
        bonusStats.append(InsightRow(title: "\"Unicorn Matches\" (Win + Auto Quest + Face the Boss)", qual: bonusStat(qual, "unicorn_matches"), playoff: bonusStat(playoff, "unicorn_matches")))

        bonusStats = filterEmptyInsights(bonusStats)
        if !bonusStats.isEmpty {
            snapshot.appendSections(["Bonus Stats (# successful / # opportunities)"])
            snapshot.appendItems(bonusStats, toSection: "Bonus Stats (# successful / # opportunities)")
        }
    }

}

