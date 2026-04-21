import Foundation
import TBAAPI

extension Event {
    func nexusTeamPitMapURL(teamNumber: Int) -> URL? {
        URL(string: "https://frc.nexus/en/event/\(key)/team/\(teamNumber)/map")
    }
}
