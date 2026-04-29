import Foundation

// Typed shape of an incoming TBA push notification, parsed from the FCM
// `userInfo` dictionary. The dispatcher always adds `notification_type` as a
// top-level data key; per-type payloads are flat key/value pairs alongside it.
//
// Reference (server-side): the-blue-alliance/the-blue-alliance
//   src/backend/common/consts/notification_type.py
//   src/backend/common/models/notifications/
enum PushNotificationPayload: Codable, Equatable {
    case match(kind: MatchKind, matchKey: String, eventKey: String, teamKey: String?)
    case silentRefresh(SilentKind)
    case unhandled(typeKey: String)

    enum MatchKind: String, Codable {
        case upcoming = "upcoming_match"
        case score = "match_score"
        case video = "match_video"
    }

    enum SilentKind: String, Codable {
        case favorites = "update_favorites"
        case subscriptions = "update_subscriptions"
    }

    static func parse(_ userInfo: [AnyHashable: Any]) -> PushNotificationPayload? {
        guard let typeKey = userInfo["notification_type"] as? String else { return nil }

        if let matchKind = MatchKind(rawValue: typeKey) {
            guard
                let matchKey = userInfo["match_key"] as? String,
                let eventKey = userInfo["event_key"] as? String
            else {
                return .unhandled(typeKey: typeKey)
            }
            let teamKey = userInfo["team_key"] as? String
            return .match(kind: matchKind, matchKey: matchKey, eventKey: eventKey, teamKey: teamKey)
        }

        if let silent = SilentKind(rawValue: typeKey) {
            return .silentRefresh(silent)
        }

        return .unhandled(typeKey: typeKey)
    }
}
