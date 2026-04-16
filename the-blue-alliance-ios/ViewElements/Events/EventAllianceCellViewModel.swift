import Foundation
import TBAAPI
import TBAData

struct EventAllianceCellViewModel {

    let allianceLevel: String?
    let allianceName: String
    let picks: [String]

    init(alliance: EventAlliance, allianceNumber: Int) {
        allianceLevel = alliance.status?.allianceLevel
        allianceName = alliance.name ?? "Alliance \(allianceNumber)"

        picks = (alliance.picks.array as? [Team] ?? []).map { $0.key }
    }

    init(alliance: Components.Schemas.EliminationAlliance, allianceNumber: Int) {
        allianceLevel = Self.allianceLevel(status: alliance.status)
        allianceName = alliance.name ?? "Alliance \(allianceNumber)"
        picks = alliance.picks
    }

    var hasAllianceLevel: Bool {
        return allianceLevel != nil
    }

    // Ported from EventStatusPlayoff.allianceLevel — "final" becomes "W"/"F"
    // based on status; everything else is the level string uppercased.
    private static func allianceLevel(status: Components.Schemas.EliminationAlliance.StatusPayload?) -> String? {
        guard let level = status?.level else { return nil }
        if level == "f", let s = status?.status {
            return s == "won" ? "W" : "F"
        }
        return level.uppercased()
    }

}
