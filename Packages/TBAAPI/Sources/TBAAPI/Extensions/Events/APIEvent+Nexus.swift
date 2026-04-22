import Foundation

extension Event {
    public func nexusTeamPitMapURL(teamNumber: Int) -> URL? {
        URL(string: "https://frc.nexus/en/event/\(key)/team/\(teamNumber)/map")
    }
}
