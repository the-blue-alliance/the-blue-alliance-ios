import Foundation

extension Event {
    public func nexusTeamPitMapURL(teamNumber: Int) -> URL? {
        let code = firstEventCode ?? key.eventCode
        return URL(
            string: "https://frc.nexus/en/event/\(year)\(code)/team/\(teamNumber)/map"
        )
    }
}
