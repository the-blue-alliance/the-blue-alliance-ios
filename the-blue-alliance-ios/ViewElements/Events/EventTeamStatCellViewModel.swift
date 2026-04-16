import Foundation

struct EventTeamStatCellViewModel {

    let statName: String
    let statValue: String

    init(statName: String, value: Float?) {
        self.statName = statName.uppercased()
        self.statValue = value.map { String(format: "%.2f", $0) } ?? "----"
    }

}
