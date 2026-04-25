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

    // Non-nil for playoff rows when the event has alliances available.
    let redAllianceBadge: AllianceLookup.Entry?
    let blueAllianceBadge: AllianceLookup.Entry?

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }

    // 2018+ alliance breakdowns expose `rp` directly; 2016 and 2017 expose
    // `tba_rpEarned` (TBA-computed from per-bonus booleans). Earlier years
    // had no RP concept, and any future year is expected to keep `rp`.
    static func rpCount(breakdown: [String: Any]?) -> Int {
        guard let breakdown else { return 0 }
        if let rp = breakdown["rp"] as? Int { return rp }
        if let rp = breakdown["tba_rpEarned"] as? Int { return rp }
        return 0
    }

    init(
        match: Match,
        event: Event,
        allianceLookup: AllianceLookup? = nil,
        baseTeamKeys: [String] = []
    ) {
        self.init(
            match: match,
            playoffType: event.playoffTypeEnum,
            allianceLookup: allianceLookup,
            baseTeamKeys: baseTeamKeys
        )
    }

    // Named so it can't be reached for by accident — primary init is preferred.
    init(
        withoutEventContextFor match: Match,
        baseTeamKeys: [String] = []
    ) {
        self.init(
            match: match,
            playoffType: nil,
            allianceLookup: nil,
            baseTeamKeys: baseTeamKeys
        )
    }

    private init(
        match: Match,
        playoffType: PlayoffType?,
        allianceLookup: AllianceLookup?,
        baseTeamKeys: [String]
    ) {
        matchName = match.friendlyName(playoffType: playoffType)
        hasVideos = !match.videos.isEmpty

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

        // Only playoff rows have alliance membership to render.
        if match.compLevel != .qm, let lookup = allianceLookup, !lookup.isEmpty {
            self.redAllianceBadge = lookup.entry(forTeamKeys: match.redAllianceTeamKeys)
            self.blueAllianceBadge = lookup.entry(forTeamKeys: match.blueAllianceTeamKeys)
        } else {
            self.redAllianceBadge = nil
            self.blueAllianceBadge = nil
        }

        let redBreakdown = match.breakdownDict?["red"] as? [String: Any]
        let blueBreakdown = match.breakdownDict?["blue"] as? [String: Any]

        redRPCount = MatchViewModel.rpCount(breakdown: redBreakdown)
        blueRPCount = MatchViewModel.rpCount(breakdown: blueBreakdown)
    }
}
