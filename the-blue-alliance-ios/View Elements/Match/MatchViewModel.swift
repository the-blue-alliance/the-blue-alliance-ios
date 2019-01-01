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
    
    let redRPCount: Int
    let blueRPCount: Int

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
        
        var redBreakdown = match.breakdown?["red"] as! [String: Any]
        var blueBreakdown = match.breakdown?["blue"] as! [String: Any]
        
        // Set RP things, specifically for 2018
        // Other years can use a similar pattern
        if match.year == 2018 {
            redRPCount = (redBreakdown["autoQuestRankingPoint"] as! Bool ? 1 : 0) + (redBreakdown["faceTheBossRankingPoint"] as! Bool ? 1 : 0)
            blueRPCount = (blueBreakdown["autoQuestRankingPoint"] as! Bool ? 1 : 0) + (blueBreakdown["faceTheBossRankingPoint"] as! Bool ? 1 : 0)
        } else {
            redRPCount = 0
            blueRPCount = 0
        }

        redAllianceWon = hasWinnersAndLosers && match.winningAlliance == "red"
        blueAllianceWon = hasWinnersAndLosers && match.winningAlliance == "blue"

        baseTeamKey = teamKey?.key
    }

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }
}
