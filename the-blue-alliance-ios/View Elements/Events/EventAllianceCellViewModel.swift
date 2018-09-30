import Foundation

struct EventAllianceCellViewModel {

    let allianceLevel: String?
    let allianceName: String?
    let picks: [String]

    init(alliance: EventAlliance) {
        allianceLevel = alliance.status?.allianceLevel
        allianceName = alliance.name

        picks = (alliance.picks?.array as? [Team] ?? []).map({ $0.key! })
    }

    var hasAllianceLevel: Bool {
        return allianceLevel != nil
    }

    var hasAllianceName: Bool {
        return allianceName != nil
    }

}
