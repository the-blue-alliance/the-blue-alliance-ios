import Foundation
import TBAAPI

struct EventAllianceCellViewModel {

    let allianceLevel: String?
    let allianceName: String
    let picks: [String]

    init(alliance: Components.Schemas.EliminationAlliance, allianceNumber: Int) {
        allianceLevel = Self.allianceLevel(status: alliance.status)
        allianceName = alliance.name ?? "Alliance \(allianceNumber)"
        picks = alliance.picks
    }

    var hasAllianceLevel: Bool {
        return allianceLevel != nil
    }

    private static func allianceLevel(status: Components.Schemas.EliminationAlliance.StatusPayload?) -> String? {
        guard let level = status?.level else { return nil }
        if level == "f", let s = status?.status {
            return s == "won" ? "W" : "F"
        }
        return level.uppercased()
    }

}
