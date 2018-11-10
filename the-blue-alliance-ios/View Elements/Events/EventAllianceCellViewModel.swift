import Foundation

struct EventAllianceCellViewModel {

    let allianceLevel: String?
    let allianceName: String
    let picks: [String]

    init(alliance: EventAlliance, allianceNumber: Int) {
        allianceLevel = alliance.status?.allianceLevel
        allianceName = alliance.name ?? "Alliance \(allianceNumber)"

        picks = (alliance.picks?.array as? [TeamKey] ?? []).map({ $0.key! })
    }

    var hasAllianceLevel: Bool {
        return allianceLevel != nil
    }

}
