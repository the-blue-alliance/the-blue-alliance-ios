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

// A TBA team key — always of the form "frc<number>" or "frc<number><suffix>"
// (e.g. "frc254", "frc5940B"). Plain `String` for now; the typealias documents
// intent and lets the helpers below read as operations over team keys.
public typealias TeamKey = String

public enum TeamKeys {
    // Strips the `frc` prefix from a team key — "frc254" → "254".
    public static func trimFRCPrefix(_ key: TeamKey) -> String {
        String(key.dropFirst(3))
    }

    // Drops a B-team suffix to get the canonical team key — "frc5940B" → "frc5940".
    // B teams aren't independent entities in TBA; they alias the parent team.
    public static func parentKey(_ key: TeamKey) -> TeamKey {
        TeamKey(key.reversed().drop(while: { !$0.isNumber }).reversed())
    }
}
