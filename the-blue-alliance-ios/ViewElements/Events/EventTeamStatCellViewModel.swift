import Foundation
import TBAData

struct EventTeamStatCellViewModel {

    let statName: String
    let statValue: String

    init(eventTeamStat: EventTeamStat?, statName: String, statKey: String) {
        statValue = {
            guard let statValue = eventTeamStat?.value(forKey: statKey) as? Double else {
                return "----"
            }
            return String(format: "%.2f", statValue)
        }()
        self.statName = statName.uppercased()
    }

}
