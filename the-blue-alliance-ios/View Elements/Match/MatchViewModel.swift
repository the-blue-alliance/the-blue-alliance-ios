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
        matchName = match.friendlyMatchName()

        hasVideos = match.videos?.count == 0

        redAlliance = (match.redAlliance?.array as? [Team])?.reversed().map({ $0.key! }) ?? []
        redScore = match.redScore?.stringValue

        blueAlliance = (match.blueAlliance?.array as? [Team])?.reversed().map({ $0.key! }) ?? []
        blueScore = match.blueScore?.stringValue

        timeString = match.timeString ?? "No Time Yet"

        // Everyone is a winner in 2015 ╮ (. ❛ ᴗ ❛.) ╭
        // Except in the Finals, where there is a winner
        // If we can't figure out a piece of information, default to yes, the match is a regular match,
        // where someone wins, and someone loses
        let hasWinnersAndLosers: Bool = {
            guard let compLevelAbbrev = match.compLevel, let compLevel = MatchCompLevel(rawValue: compLevelAbbrev) else {
                return true
            }
            guard let year16 = match.event?.year else {
                return true
            }
            if Int(year16) == 2015 && compLevel != MatchCompLevel.final {
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
