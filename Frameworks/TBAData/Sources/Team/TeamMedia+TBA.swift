import CoreData
import Foundation
import TBAKit
import UIKit

public enum MediaError: Error {
    case error(String)
}

extension MediaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .error(message):
            return NSLocalizedString(message, comment: "Media error")
        }
    }
}

public enum MediaType: String {
    case youtubeVideo = "youtube"
    case cdPhotoThread = "cdphotothread"
    case imgur = "imgur"
    case facebookProfile = "facebook-profile"
    case youtubeChannel = "youtube-channel"
    case twitterProfile = "twitter-profile"
    case githubProfile = "github-profile"
    case instagramProfile = "instagram-profile"
    case periscopeProfile = "periscope-profile"
    case grabcad = "grabcad"
    case pinterestProfile = "pinterest-profile"
    case snapchatProfile = "snapchat-profile"
    case twitchChannel = "twitch-channel"
    case instagramImage = "instagram-image"

    public static var imageTypes: [String] {
        return [MediaType.cdPhotoThread.rawValue,
                MediaType.imgur.rawValue,
                MediaType.instagramImage.rawValue,
                MediaType.grabcad.rawValue]
    }

    public static var socialTypes: [String] {
        return [MediaType.facebookProfile.rawValue,
                MediaType.twitterProfile.rawValue,
                MediaType.youtubeChannel.rawValue,
                MediaType.githubProfile.rawValue,
                MediaType.instagramProfile.rawValue,
                MediaType.periscopeProfile.rawValue,
                MediaType.pinterestProfile.rawValue,
                MediaType.snapchatProfile.rawValue,
                MediaType.twitchChannel.rawValue]
    }

    // TODO: profile_urls

}

extension TeamMedia {

    public var imageDirectURL: URL? {
        guard let directURL = getValue(\TeamMedia.directURL) else {
            return nil
        }
        return URL(string: directURL)
    }

}

extension TeamMedia: Playable {

    public var youtubeKey: String? {
        if type == MediaType.youtubeVideo.rawValue {
            return getValue(\TeamMedia.foreignKey)
        }
        return nil
    }

}

extension TeamMedia: Managed {

    public var isOrphaned: Bool {
        return team == nil
    }

}
