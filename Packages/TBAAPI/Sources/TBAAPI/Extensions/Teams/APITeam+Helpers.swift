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

    // Returns nil when nickname is empty or equals FIRST's "Team N" fallback
    // placeholder. Use this wherever showing the fallback would duplicate the
    // team-number line that is already displayed separately.
    public var meaningfulNickname: String? {
        Self.meaningful(nickname, forTeamNumber: teamNumber)
    }

    // Static variant for raw strings that don't already have a TeamDisplayable
    // context (e.g. partial nicknames passed in before a full team is loaded).
    public static func meaningful(_ nickname: String?, forTeamNumber teamNumber: Int) -> String? {
        guard let nickname, !nickname.isEmpty,
              nickname != "Team \(teamNumber)" else { return nil }
        return nickname
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

extension TeamKey {
    public var trimPrefix: String {
        String(dropFirst(3))
    }

    public var teamNumber: Int? {
        Int(trimPrefix)
    }

    // B teams (e.g. "frc5940B") aren't independent entities in TBA — they
    // alias the parent team. Walk from the end and drop non-digits to
    // recover the canonical key.
    public var parentKey: TeamKey {
        TeamKey(reversed().drop(while: { !$0.isNumber }).reversed())
    }
}
