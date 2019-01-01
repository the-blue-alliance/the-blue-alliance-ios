import Foundation

struct MatchViewModel {

    let matchName: String

    let hasVideos: Bool

    let redAlliance: [String]
    let redScore: String?

    let blueAlliance: [String]
    let blueScore: String?

    let timeString: String

    let redAllianceWon: Bool
    let blueAllianceWon: Bool
    
    var redRPCount: Int = 0
    var blueRPCount: Int = 0

    let baseTeamKey: String?

    init(match: Match, teamKey: TeamKey? = nil) {
        // TODO: Support all alliances
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/274
        matchName = match.friendlyName

        hasVideos = match.videos?.count == 0

        redAlliance = match.redAllianceTeamNumbers
        redScore = match.redAlliance?.score?.stringValue

        blueAlliance = match.blueAllianceTeamNumbers
        blueScore = match.blueAlliance?.score?.stringValue

        timeString = match.timeString ?? "No Time Yet"

        // Everyone is a winner in 2015 ╮ (. ❛ ᴗ ❛.) ╭
        // Except in the Finals, where there is a winner
        // If we can't figure out a piece of information, default to yes, the match is a regular match,
        // where someone wins, and someone loses
        let hasWinnersAndLosers: Bool = {
            if match.year == 2015 && match.compLevel != .final {
                return false
            }
            return true
        }()
        
        redAllianceWon = hasWinnersAndLosers && match.winningAlliance == "red"
        blueAllianceWon = hasWinnersAndLosers && match.winningAlliance == "blue"
        
        baseTeamKey = teamKey?.key
        
        // TODO: Support all alliances
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/274
        let redBreakdown = match.breakdown?["red"] as? [String: Any]
        let blueBreakdown = match.breakdown?["blue"] as? [String: Any]
        
        // Set RP things, specifically for 2018
        // Other years can use a similar pattern
        var rpName1: String?
        var rpName2: String?

        switch match.year {
        case 2016:
            rpName1 = "teleopDefensesBreached"
            rpName2 = "teleopTowerCaptured"
        case 2017:
            rpName1 = "kPaRankingPointAchieved"
            rpName2 = "rotorRankingPointAchieved"
        case 2018:
            rpName1 = "autoQuestRankingPoint"
            rpName2 = "faceTheBossRankingPoint"
        default:
            break
        }
        
        let breakdownKeys: [String] = [rpName1, rpName2].compactMap({ $0 })
        redRPCount = MatchViewModel.calculateRP(breakdown: redBreakdown, breakdownKeys: breakdownKeys)
        blueRPCount = MatchViewModel.calculateRP(breakdown: blueBreakdown, breakdownKeys: breakdownKeys)
    }

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
}
