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

    let baseTeamKey: String?

    init(match: Match, team: Team? = nil) {
        // TODO: This isn't very robust - only supports red/blue
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
            if Int(match.event!.year) == 2015 && match.compLevel != .final {
                return false
            }
            return true
        }()

        redAllianceWon = hasWinnersAndLosers && match.winningAlliance == "red"
        blueAllianceWon = hasWinnersAndLosers && match.winningAlliance == "blue"

        baseTeamKey = team?.key
    }

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }

}
