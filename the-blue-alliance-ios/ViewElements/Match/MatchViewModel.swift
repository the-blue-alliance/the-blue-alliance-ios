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

    var redRPCount: [Int] = [0, 0]
    var blueRPCount: [Int] = [0, 0]

    let baseTeamKeys: [String]

    // Non-nil for playoff rows when the event has alliances available.
    let redAllianceBadge: AllianceLookup.Entry?
    let blueAllianceBadge: AllianceLookup.Entry?

    var hasScores: Bool {
        return blueScore != nil && redScore != nil
    }

    // Counts bonus-objective RPs for `year` by checking the per-game booleans
    // in `breakdown`. Mirrors the web frontend's `match_table_cell_macros.html`
    // so unmapped seasons fail closed (0 dots) instead of risking a wrong
    // count when the season's win RP changes (e.g. 2 → 3 in 2025).
    static func rpCount(breakdown: [String: Any]?, year: Int) -> Int {
        guard let breakdown else { return 0 }
        return bonusKeys(year: year).reduce(0) { count, key in
            count + ((breakdown[key] as? Bool) == true ? 1 : 0)
        }
    }

    private static func bonusKeys(year: Int) -> [String] {
        switch year {
        case 2016: return ["teleopDefensesBreached", "teleopTowerCaptured"]
        case 2017: return ["kPaRankingPointAchieved", "rotorRankingPointAchieved"]
        case 2018: return ["autoQuestRankingPoint", "faceTheBossRankingPoint"]
        case 2019: return ["completeRocketRankingPoint", "habDockingRankingPoint"]
        case 2020: return ["shieldEnergizedRankingPoint", "shieldOperationalRankingPoint"]
        case 2022: return ["cargoBonusRankingPoint", "hangarBonusRankingPoint"]
        case 2023: return ["sustainabilityBonusAchieved", "activationBonusAchieved"]
        case 2024: return ["melodyBonusAchieved", "ensembleBonusAchieved"]
        case 2025: return ["autoBonusAchieved", "coralBonusAchieved", "bargeBonusAchieved"]
        case 2026: return ["energizedAchieved", "superchargedAchieved", "traversalAchieved"]
        default: return []
        }
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

        redRPCount = [MatchViewModel.rpCount(breakdown: redBreakdown, year: matchYear), MatchViewModel.bonusKeys(year: matchYear).count]
        blueRPCount = [MatchViewModel.rpCount(breakdown: blueBreakdown, year: matchYear), MatchViewModel.bonusKeys(year: matchYear).count]
    }
}
