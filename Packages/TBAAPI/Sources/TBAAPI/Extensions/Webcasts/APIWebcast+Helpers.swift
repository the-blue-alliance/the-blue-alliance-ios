import Foundation

extension Webcast {

    public var typeString: String { _type.rawValue }

    public var displayName: String {
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

    public var urlString: String? {
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

    public var dateParsed: Date? {
        guard let date else { return nil }
        return TBAAPI.dateFormatter.date(from: date)
    }
}
