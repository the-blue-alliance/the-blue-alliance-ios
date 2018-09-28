import Foundation

class MatchCellViewModel {

    private let match: Match
    let team: Team?

    init(match: Match, team: Team? = nil) {
        self.match = match
        self.team = team
    }

    // MARK: - Public Methods

    var matchName: String {
        return match.friendlyMatchName()
    }

    var hasVideos: Bool {
        return match.videos?.count == 0
    }

    var redAlliance: [Team] {
        guard let redAlliance = match.redAlliance?.array as? [Team] else {
            return []
        }
        return redAlliance.reversed()
    }

    var redScore: String? {
        return match.redScore?.stringValue
    }

    var blueAlliance: [Team] {
        guard let blueAlliance = match.blueAlliance?.array as? [Team] else {
            return []
        }
        return blueAlliance.reversed()
    }

    var blueScore: String? {
        return match.blueScore?.stringValue
    }

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }

    var timeString: String {
        guard let timeString = match.timeString else {
            return "No Time Yet"
        }
        return timeString
    }

    // Everyone is a winner in 2015 ╮ (. ❛ ᴗ ❛.) ╭
    // Except in the Finals, where there is a winner
    private var hasWinnersAndLosers: Bool {
        // If we can't figure out a piece of information, default to yes, the match is a regular match,
        // where someone wins, and someone loses
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
    }

    var redAllianceWon: Bool {
        return hasWinnersAndLosers && match.winningAlliance == "red"
    }

    var blueAllianceWon: Bool {
        return hasWinnersAndLosers && match.winningAlliance == "blue"
    }

}
