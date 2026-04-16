import Foundation
import TBAAPI

extension Components.Schemas.Webcast {

    // Matches the string enum in TBAData's `Webcast.type`.
    var typeString: String { _type.rawValue }

    var displayName: String {
        switch _type {
        case .youtube:
            return "YouTube"
        case .twitch:
            return "Twitch"
        case .directLink:
            // Convert the direct link string into just the domain (e.g. "espn.com").
            guard let url = URL(string: channel), let host = url.host else {
                return "website"
            }
            let parts = host.split(separator: ".")
            return parts.dropFirst(max(parts.count - 2, 0)).joined(separator: ".")
        default:
            return _type.rawValue
        }
    }

    var urlString: String? {
        switch _type {
        case .twitch:
            return "https://twitch.tv/\(channel)"
        case .youtube:
            return "https://www.youtube.com/watch?v=\(channel)"
        case .directLink:
            return channel
        default:
            return nil
        }
    }

    var dateParsed: Date? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: date)
    }
}
