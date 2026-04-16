import Foundation
import TBAAPI

extension Components.Schemas.Team {

    // Matches the TBAData.Team.teamNumberNickname ("Team 254").
    var teamNumberNickname: String { "Team \(teamNumber)" }

    // Prefer the FIRST-supplied nickname, fall back to "Team N".
    var displayNickname: String {
        nickname.isEmpty ? teamNumberNickname : nickname
    }

    var hasWebsite: Bool {
        guard let website else { return false }
        return !website.isEmpty
    }

    var locationString: String? {
        let parts = [city, stateProv, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? locationName : parts.joined(separator: ", ")
    }
}

// Strips the `frc` prefix from a team key — "frc254" → "254".
enum TeamKey {
    static func trimFRCPrefix(_ key: String) -> String {
        key.hasPrefix("frc") ? String(key.dropFirst(3)) : key
    }
}
