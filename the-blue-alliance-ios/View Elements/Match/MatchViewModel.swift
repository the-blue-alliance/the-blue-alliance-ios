import Foundation

struct MatchViewModel {

    let matchName: String

    let hasVideos: Bool

    let redAlliance: [String]
    let redScore: String?
    let redRP: String?

    let blueAlliance: [String]
    let blueScore: String?
    let blueRP: String?

    let timeString: String

    let redAllianceWon: Bool
    let blueAllianceWon: Bool

    let baseTeamKey: String?

    init(match: Match, teamKey: TeamKey? = nil) {
        // TODO: Support all alliances
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/274
        matchName = match.friendlyName

        hasVideos = match.videos?.count == 0

        redAlliance = match.redAllianceTeamNumbers
        redScore = match.redAlliance?.score?.stringValue
        redRP = "•"

        blueAlliance = match.blueAllianceTeamNumbers
        blueScore = match.blueAlliance?.score?.stringValue
        blueRP = "•"

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
    }

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }

}
