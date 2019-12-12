import Foundation

public enum MatchVideoType: String {
    case youtube = "youtube"
    case tba = "tba"
}

extension MatchVideo: Playable {

    public var youtubeKey: String? {
        if type == .youtube {
            return key
        }
        return nil
    }

}

extension MatchVideo: Managed {

    public var isOrphaned: Bool {
        return matches.count == 0
    }

}
