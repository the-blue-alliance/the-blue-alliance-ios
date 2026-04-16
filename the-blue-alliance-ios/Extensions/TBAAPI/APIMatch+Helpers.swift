import Foundation
import TBAAPI

extension Components.Schemas.Match.CompLevelPayload {

    var sortOrder: Int {
        switch self {
        case .qm: return 0
        case .ef: return 1
        case .qf: return 2
        case .sf: return 3
        case .f:  return 4
        }
    }

    var level: String {
        switch self {
        case .qm: return "Qualification"
        case .ef: return "Octofinals"
        case .qf: return "Quarterfinals"
        case .sf: return "Semifinals"
        case .f:  return "Finals"
        }
    }

    var levelShort: String {
        switch self {
        case .qm: return "Quals"
        case .ef: return "Eighths"
        case .qf: return "Quarters"
        case .sf: return "Semis"
        case .f:  return "Finals"
        }
    }
}

extension Components.Schemas.Match {

    var compLevelString: String { compLevel.rawValue }

    var compLevelSortOrder: Int { compLevel.sortOrder }

    var friendlyName: String {
        if compLevel == .qm {
            return "\(compLevel.levelShort) \(matchNumber)"
        }
        return "\(compLevel.levelShort) \(setNumber)-\(matchNumber)"
    }

    var redAllianceTeamKeys: [String] { alliances.red.teamKeys }
    var blueAllianceTeamKeys: [String] { alliances.blue.teamKeys }
    var dqTeamKeys: [String] { alliances.red.dqTeamKeys + alliances.blue.dqTeamKeys }
    var allTeamKeys: [String] { redAllianceTeamKeys + blueAllianceTeamKeys }

    // Start time, actual or a guess — matches the TBAData precedence:
    // actual > predicted > scheduled.
    var startTime: Int? {
        if let actual = actualTime { return Int(actual) }
        if let predicted = predictedTime { return Int(predicted) }
        if let scheduled = time { return Int(scheduled) }
        return nil
    }

    var startTimeString: String? {
        guard let startTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mm a"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTime)))
    }

    // Year parsed from the match key (first 4 chars of `yyyy[EVENT]_...`).
    var year: Int? { Int(key.prefix(4)) }

    // Event key parsed from the match key (everything before the first `_`).
    var eventKeyFromMatchKey: String {
        String(key.split(separator: "_").first ?? Substring(eventKey))
    }

    // Score breakdown serialized back to `[String: Any]` so the existing
    // per-year `MatchBreakdownConfigurator` helpers keep working unchanged.
    var breakdownDict: [String: Any]? {
        guard let scoreBreakdown else { return nil }
        guard let data = try? JSONEncoder().encode(scoreBreakdown),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return obj
    }

    var winningAllianceString: String {
        winningAlliance.rawValue
    }
}

// Convenience: parse year and event key from any match key (used before the
// full match struct has been fetched).
enum MatchKey {
    static func year(from matchKey: String) -> Int? { Int(matchKey.prefix(4)) }
    static func eventKey(from matchKey: String) -> String {
        String(matchKey.split(separator: "_").first ?? Substring(matchKey))
    }
}
