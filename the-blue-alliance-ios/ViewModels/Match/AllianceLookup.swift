import Foundation
import TBAAPI

struct AllianceLookup {

    struct Entry: Hashable {
        let number: Int
        let name: String?

        // nil when the API returned the default `"Alliance N"` placeholder
        // rather than a sponsor/division name like "DTE Energy" or "Archimedes".
        var customName: String? {
            guard let name, !name.isEmpty,
                name.caseInsensitiveCompare("Alliance \(number)") != .orderedSame
            else { return nil }
            return name
        }

        var hasCustomName: Bool { customName != nil }
    }

    // One Entry per teamKey: a team can only be on one alliance at a time
    // (FRC rules), so picks and backup._in across alliances never collide.
    private let byTeamKey: [String: Entry]

    init(alliances: [EliminationAlliance]) {
        var map: [String: Entry] = [:]
        for (index, alliance) in alliances.enumerated() {
            let entry = Entry(number: index + 1, name: alliance.name)
            for teamKey in alliance.picks {
                map[teamKey] = entry
            }
            if let backup = alliance.backup, !backup._in.isEmpty {
                map[backup._in] = entry
            }
        }
        self.byTeamKey = map
    }

    func entry(forTeamKeys keys: [String]) -> Entry? {
        for key in keys {
            if let entry = byTeamKey[key] { return entry }
        }
        return nil
    }

    var isEmpty: Bool { byTeamKey.isEmpty }
}
