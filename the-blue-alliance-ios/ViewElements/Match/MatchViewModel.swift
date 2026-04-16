import Foundation
import TBAAPI

struct MatchViewModel {

    let matchName: String

    let hasVideos: Bool

    let redAlliance: [String]
    let redScore: Int?

    let blueAlliance: [String]
    let blueScore: Int?

    let dqs: [String]

    let timeString: String

    let redAllianceWon: Bool
    let blueAllianceWon: Bool

    var redRPCount: Int = 0
    var blueRPCount: Int = 0

    let baseTeamKeys: [String]

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }

    static func calculateRP(breakdown: [String: Any]?, breakdownKeys: [String]) -> Int {
        var rpCount: Int = 0

        for key in breakdownKeys {
            if let breakdown = breakdown?[key] as? Bool {
                rpCount += breakdown ? 1 : 0
            }
        }
        return rpCount
    }

    init(apiMatch match: Components.Schemas.Match, baseTeamKeys: [String] = []) {
        matchName = match.friendlyName
        hasVideos = match.videos.isEmpty

        redAlliance = match.redAllianceTeamKeys
        redScore = match.alliances.red.score < 0 ? nil : match.alliances.red.score

        blueAlliance = match.blueAllianceTeamKeys
        blueScore = match.alliances.blue.score < 0 ? nil : match.alliances.blue.score

        dqs = match.dqTeamKeys
        timeString = match.startTimeString ?? "No Time Yet"

        // 2015 non-final matches have no winners or losers.
        let matchYear = match.year ?? 0
        let hasWinnersAndLosers = !(matchYear == 2015 && match.compLevel != .f)
        redAllianceWon = hasWinnersAndLosers && match.winningAllianceString == "red"
        blueAllianceWon = hasWinnersAndLosers && match.winningAllianceString == "blue"

        self.baseTeamKeys = baseTeamKeys

        let redBreakdown = match.breakdownDict?["red"] as? [String: Any]
        let blueBreakdown = match.breakdownDict?["blue"] as? [String: Any]

        var rpName1: String?
        var rpName2: String?
        switch matchYear {
        case 2016:
            rpName1 = "teleopDefensesBreached"
            rpName2 = "teleopTowerCaptured"
        case 2017:
            rpName1 = "kPaRankingPointAchieved"
            rpName2 = "rotorRankingPointAchieved"
        case 2018:
            rpName1 = "autoQuestRankingPoint"
            rpName2 = "faceTheBossRankingPoint"
        case 2019:
            rpName1 = "completeRocketRankingPoint"
            rpName2 = "habDockingRankingPoint"
        case 2020, 2021:
            rpName1 = "shieldEnergizedRankingPoint"
            rpName2 = "shieldOperationalRankingPoint"
        case 2022:
            rpName1 = "cargoBonusRankingPoint"
            rpName2 = "hangarBonusRankingPoint"
        default:
            break
        }

        let breakdownKeys: [String] = [rpName1, rpName2].compactMap { $0 }
        redRPCount = MatchViewModel.calculateRP(breakdown: redBreakdown, breakdownKeys: breakdownKeys)
        blueRPCount = MatchViewModel.calculateRP(breakdown: blueBreakdown, breakdownKeys: breakdownKeys)
    }
}
