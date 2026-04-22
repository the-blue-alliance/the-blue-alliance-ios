import Foundation

public protocol TeamDisplayable {
    var key: String { get }
    var teamNumber: Int { get }
    var nickname: String { get }
    var name: String { get }
    var city: String? { get }
    var stateProv: String? { get }
    var country: String? { get }
}

extension TeamDisplayable {
    // Ex: "Team 254"
    public var teamNumberNickname: String { "Team \(teamNumber)" }

    // Prefer the FIRST-supplied nickname, fall back to "Team N".
    public var displayNickname: String {
        nickname.isEmpty ? teamNumberNickname : nickname
    }

    public var locationString: String? {
        let parts = [city, stateProv, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

extension TeamSimple: TeamDisplayable {}

extension Team: TeamDisplayable {

    public var hasWebsite: Bool {
        guard let website else { return false }
        return !website.isEmpty
    }

    // `Team` carries the parsed `locationName` field; use it as a fallback when
    // city/state/country are all empty. `TeamSimple` lacks this field.
    public var locationString: String? {
        let parts = [city, stateProv, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? locationName : parts.joined(separator: ", ")
    }
}

// Strips the `frc` prefix from a team key — "frc254" → "254".
public enum TeamKey {
    public static func trimFRCPrefix(_ key: String) -> String {
        key.hasPrefix("frc") ? String(key.dropFirst(3)) : key
    }
}
