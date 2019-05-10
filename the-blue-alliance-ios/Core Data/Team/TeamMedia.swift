import CoreData
import Foundation
import TBAKit
import UIKit

enum MediaError: Error {
    case error(String)
}

extension MediaError: LocalizedError {
    var errorDescription: String? {
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

    static var imageTypes: [String] {
        return [MediaType.cdPhotoThread.rawValue,
                MediaType.imgur.rawValue,
                MediaType.instagramImage.rawValue,
                MediaType.grabcad.rawValue]
    }

    static var socialTypes: [String] {
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

    var image: UIImage? {
        get {
            if let mediaData = mediaData {
                return UIImage(data: mediaData)
            }
            return nil
        }
        set {
            mediaData = newValue?.pngData()
            mediaError = nil
        }
    }

    var imageError: Error? {
        get {
            return mediaError
        }
        set {
            mediaError = newValue
            mediaData = nil
        }
    }

    public var imageDirectURL: URL? {
        guard let directURL = directURL else {
            return nil
        }
        return URL(string: directURL)
    }

}

extension TeamMedia: Playable {

    var youtubeKey: String? {
        if type == MediaType.youtubeVideo.rawValue {
            return getValue(\TeamMedia.foreignKey)
        }
        return nil
    }

}

extension TeamMedia: Managed {

    /**
     Insert a Team Media with values from a TBAKit Media model in to the managed object context.

     - Parameter model: The TBAKit Team representation to set values from.

     - Parameter year: The year the Team Media relates to.

     - Parameter context: The NSManagedContext to insert the Team Media in to.

     - Returns: The inserted Team Media.
     */
    static func insert(_ model: TBAMedia, year: Int, in context: NSManagedObjectContext) -> TeamMedia {
        var mediaPredicate: NSPredicate?
        if let key = model.key {
            mediaPredicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                         #keyPath(TeamMedia.key), key,
                                         #keyPath(TeamMedia.type), model.type)
        } else if let foreignKey = model.foreignKey {
            mediaPredicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                         #keyPath(TeamMedia.foreignKey), foreignKey,
                                         #keyPath(TeamMedia.type), model.type)
        }
        guard let predicate = mediaPredicate else {
            fatalError("No way to filter media")
        }

        let yearPredicate = NSPredicate(format: "%K == %ld",
                                        #keyPath(TeamMedia.year), year)

        return findOrCreate(in: context, matching: NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, yearPredicate])) { (media) in
            // Required: type, year
            media.key = model.key
            media.type = model.type
            media.year = year as NSNumber
            media.foreignKey = model.foreignKey
            media.details = model.details
            media.preferred = model.preferred ?? false
            media.viewURL = model.viewURL
            media.directURL = model.directURL
        }
    }

    var isOrphaned: Bool {
        return team == nil
    }

}
