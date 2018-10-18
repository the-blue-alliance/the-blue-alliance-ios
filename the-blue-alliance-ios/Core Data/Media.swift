import Foundation
import TBAKit
import CoreData

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

extension Media: Managed, Playable {

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

    var youtubeKey: String? {
        if type == MediaType.youtubeVideo.rawValue {
            return foreignKey
        }
        return nil
    }

    static func insert(with model: TBAMedia, in year: Int, for team: Team, in context: NSManagedObjectContext) -> Media {
        var mediaPredicate: NSPredicate?
        if let key = model.key {
            mediaPredicate = NSPredicate(format: "key == %@ AND type == %@", key, model.type)
        } else if let foreignKey = model.foreignKey {
            mediaPredicate = NSPredicate(format: "foreignKey == %@ AND type == %@", foreignKey, model.type)
        }
        guard let predicate = mediaPredicate else {
            fatalError("No way to filter media")
        }
        return findOrCreate(in: context, matching: predicate) { (media) in
            // Required: type, year
            media.key = model.key
            media.type = model.type
            media.year = Int16(year)
            media.foreignKey = model.foreignKey
            media.details = model.details
            media.preferred = model.preferred ?? false

            media.team = team
        }
    }

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/master/models/media.py#L92

    public var viewImageURL: URL? {
        if type! == MediaType.cdPhotoThread.rawValue {
            return cdphotothreadThreadURL
        } else if type! == MediaType.imgur.rawValue {
            return imgurURL
        } else if type! == MediaType.grabcad.rawValue {
            return grabcadURL
        } else if type! == MediaType.instagramImage.rawValue {
            return instagramURL
        } else {
            return nil
        }
    }

    public var imageDirectURL: URL? {
        // Largest image that isn't max resolution (which can be arbitrarily huge)
        if type! == MediaType.cdPhotoThread.rawValue {
            return cdphotothreadImageSize(.medium)
        } else if type! == MediaType.imgur.rawValue {
            return imgurImageSize(.direct)
        } else if type! == MediaType.grabcad.rawValue {
            return grabcadDirectURL
        } else if type! == MediaType.instagramImage.rawValue {
            return instagramDirectURL(.large)
        } else {
            return nil
        }
    }

}

// CDPhotoThread URLs
extension Media {

    public enum CDPhotoTreadSize: String {
        case small = "_s"
        case medium = "_m"
        case large = "_l"
    }

    fileprivate var cdphotothreadImageURL: URL? {
        guard let image_partial = details?["image_partial"] as? String else {
            return nil
        }
        return URL(string: "http://www.chiefdelphi.com/media/img/\(image_partial)")
    }

    private func cdphotothreadImageSize(_ size: CDPhotoTreadSize) -> URL? {
        guard let url = cdphotothreadImageURL else {
            return nil
        }
        return URL(string: url.absoluteString.replacingOccurrences(of: CDPhotoTreadSize.large.rawValue, with: size.rawValue))
    }

    private var cdphotothreadThreadURL: URL? {
        guard let foreignKey = foreignKey else {
            return nil
        }
        return URL(string: "http://www.chiefdelphi.com/media/photos/\(foreignKey)")
    }

}

// Instagram URLs
extension Media {

    public enum ImgurImageSize: String {
        case small = "s"
        case medium = "m"
        case direct = "h"
    }

    fileprivate var imgurURL: URL? {
        guard let foreignKey = foreignKey else {
            return nil
        }
        return URL(string: "https://imgur.com/\(foreignKey)")
    }

    private func imgurImageSize(_ size: ImgurImageSize) -> URL? {
        guard let foreignKey = foreignKey else {
            return nil
        }
        return URL(string: "https://i.imgur.com/\(foreignKey)\(size.rawValue).jpg")
    }

}

// Instagram URLs
extension Media {

    public enum InstagramImageSize: String {
        case thumbnail = "t"
        case medium = "m"
        case large = "l"
    }

    fileprivate var instagramURL: URL? {
        guard let foreignKey = foreignKey else {
            return nil
        }
        return URL(string: "https://www.instagram.com/p/\(foreignKey)")
    }

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/fe43a0ce3b1bf2f74de945765f4e04f37eb6112d/models/media.py#L158
    private func instagramDirectURL(_ size: InstagramImageSize) -> URL? {
        guard let instagramURL = instagramURL else {
            return nil
        }
        return URL(string: "\(instagramURL)/media/?size=\(size.rawValue)")
    }

}

// Grabcad URLs
extension Media {

    fileprivate var grabcadURL: URL? {
        guard let foreignKey = foreignKey else {
            return nil
        }
        return URL(string: "https://grabcad.com/library/\(foreignKey)")
    }

    fileprivate var grabcadDirectURL: URL? {
        guard let modelImage = details?["model_image"] as? String else {
            return nil
        }
        return URL(string: modelImage.replacingOccurrences(of: "card.jpg", with: "large.png"))
    }

}
