import Foundation

extension CompLevel {

    public var sortOrder: Int {
        switch self {
        case .qm: return 0
        case .ef: return 1
        case .qf: return 2
        case .sf: return 3
        case .f: return 4
        }
    }

    public var level: String {
        switch self {
        case .qm: return "Qualification"
        case .ef: return "Eighth-Finals"
        case .qf: return "Quarterfinals"
        case .sf: return "Semifinals"
        case .f: return "Finals"
        }
    }

    public var levelShort: String {
        switch self {
        case .qm: return "Quals"
        case .ef: return "Eighths"
        case .qf: return "Quarters"
        case .sf: return "Semis"
        case .f: return "Finals"
        }
    }
}

extension Match {

    public var compLevelString: String { compLevel.rawValue }

    public var compLevelSortOrder: Int { compLevel.sortOrder }

    // Round robin prelims and 2023+ double elim pre-finals are both stored
    // as `sf` (round robin sets match_number 1..15; double elim sets
    // set_number 1..13 with match_number 1) — so "Semis N-M" is misleading
    // for those formats. Finals are `f` for both.
    public func friendlyName(playoffType: PlayoffType?) -> String {
        if compLevel == .qm {
            return "\(compLevel.levelShort) \(matchNumber)"
        }
        switch playoffType?.kind {
        case .roundRobin6Team:
            if compLevel == .f { return "Finals \(matchNumber)" }
            return "Match \(matchNumber)"
        case .doubleElim8Team, .doubleElim4Team:
            if compLevel == .f { return "Finals \(matchNumber)" }
            return "Match \(setNumber)"
        case .averageScore8Team:
            return "\(compLevel.levelShort) \(matchNumber)"
        case .bo3Finals, .bo5Finals:
            return "Finals \(matchNumber)"
        default:
            return "\(compLevel.levelShort) \(setNumber)-\(matchNumber)"
        }
    }

    public var redAllianceTeamKeys: [String] { alliances.red.teamKeys }
    public var blueAllianceTeamKeys: [String] { alliances.blue.teamKeys }
    public var dqTeamKeys: [String] { alliances.red.dqTeamKeys + alliances.blue.dqTeamKeys }
    public var allTeamKeys: [String] { redAllianceTeamKeys + blueAllianceTeamKeys }

    // Start time
    // actual > predicted > scheduled.
    public var startTime: Int? {
        if let actual = actualTime { return Int(actual) }
        if let predicted = predictedTime { return Int(predicted) }
        if let scheduled = time { return Int(scheduled) }
        return nil
    }

    public var startTimeString: String? {
        guard let startTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mm a"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTime)))
    }

    // Year parsed from the match key (first 4 chars of `yyyy[EVENT]_...`).
    public var year: Int? { Int(key.prefix(4)) }

    // Event key parsed from the match key (everything before the first `_`).
    public var eventKeyFromMatchKey: String {
        String(key.split(separator: "_").first ?? Substring(eventKey))
    }

    // Score breakdown serialized back to `[String: Any]` so the existing
    // per-year `MatchBreakdownConfigurator` helpers keep working unchanged.
    public var breakdownDict: [String: Any]? {
        guard let scoreBreakdown else { return nil }
        guard let data = try? JSONEncoder().encode(scoreBreakdown),
            let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        return obj
    }

    public var winningAllianceString: String {
        winningAlliance.rawValue
    }
}

// Convenience: parse year and event key from any match key (used before the
// full match struct has been fetched).
public enum MatchKey {
    public static func year(from matchKey: String) -> Int? { Int(matchKey.prefix(4)) }
    public static func eventKey(from matchKey: String) -> String {
        String(matchKey.split(separator: "_").first ?? Substring(matchKey))
    }
}
