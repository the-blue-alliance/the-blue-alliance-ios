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

    var youtubeKey: String? {
        if type == MediaType.youtubeVideo.rawValue {
            return foreignKey
        }
        return nil
    }

    static func insert(with model: TBAMedia, for year: Int, in context: NSManagedObjectContext) -> Media {
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
        }
    }

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/master/models/media.py#L92

    public var viewImageURL: URL? {
        if type! == MediaType.cdPhotoThread.rawValue {
            return cdphotothreadImageURL
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
            return cdphotothreadImageURLMed
        } else if type! == MediaType.imgur.rawValue {
            return imgurDirectURL
        } else if type! == MediaType.grabcad.rawValue {
            return grabcadDirectURL
        } else if type! == MediaType.instagramImage.rawValue {
            return instagramDirectURL
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

    fileprivate var cdphotothreadImageURLMed: URL? {
        return cdphotothreadImageSize(.medium)
    }

    private var cdphotothreadImageURLSm: URL? {
        return cdphotothreadImageSize(.medium)
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

    private var imgurDirectURLSm: URL? {
        return imgurImageSize(.small)
    }

    private var imgurDirectURLMed: URL? {
        return imgurImageSize(.medium)
    }

    fileprivate var imgurDirectURL: URL? {
        return imgurImageSize(.direct)
    }

}

// Instagram URLs
extension Media {

    fileprivate var instagramURL: URL? {
        guard let foreignKey = foreignKey else {
            return nil
        }
        return URL(string: "https://www.instagram.com/p/\(foreignKey)")
    }

    fileprivate var instagramDirectURL: URL? {
        guard let thumbnail = details?["thumbnail_url"] as? String else {
            return nil
        }
        return URL(string: thumbnail)
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
