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

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/master/models/media.py#L92
    public var viewImageURL: URL? {
        guard let type = type else {
            return nil
        }

        if type == MediaType.cdPhotoThread.rawValue {
            return cdphotothreadThreadURL
        } else if type == MediaType.imgur.rawValue {
            return imgurURL
        } else if type == MediaType.grabcad.rawValue {
            return grabcadURL
        } else if type == MediaType.instagramImage.rawValue {
            return instagramURL
        } else {
            return nil
        }
    }

    public var imageDirectURL: URL? {
        guard let type = type else {
            return nil
        }

        // Largest image that isn't max resolution (which can be arbitrarily huge)
        if type == MediaType.cdPhotoThread.rawValue {
            return cdphotothreadImageSize(.medium)
        } else if type == MediaType.imgur.rawValue {
            return imgurImageSize(.direct)
        } else if type == MediaType.grabcad.rawValue {
            return grabcadDirectURL
        } else if type == MediaType.instagramImage.rawValue {
            return instagramDirectURL(.large)
        } else {
            return nil
        }
    }

}

extension TeamMedia: Playable {

    var youtubeKey: String? {
        if type == MediaType.youtubeVideo.rawValue {
            return foreignKey
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
        // Uhhh filter by Year too, right?
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
        }
    }

    /**
     Insert an array of Team Medias with values from TBAKit Media models in to the managed object context. This method manages setting up a Team Media and Team relationship and deleting orphaned Team Media objects.

     - Parameter media: The TBAKit Media representations to set values from.

     - Parameter team: The Team to relate the Media too.

     - Parameter year: The year the Team Media relates to.

     - Parameter context: The NSManagedContext to insert the Team Media in to.

     - Returns: The inserted Team Media.
     */
    static func insert(_ media: [TBAMedia], team: Team, year: Int, in context: NSManagedObjectContext) {
        // Fetch all of the previous TeamMedia for this Team and year
        let oldMedia = TeamMedia.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %@ AND %K == %ld",
                                       #keyPath(TeamMedia.team.key), team.key!,
                                       #keyPath(TeamMedia.year), year)
        }

        // Insert new TeamMedia for this year
        let media = media.map({ (model: TBAMedia) -> TeamMedia in
            let m = TeamMedia.insert(model, year: year, in: context)
            team.addToMedia(m)
            return m
        })

        // Delete orphaned TeamMedia for this Event
        Set(oldMedia).subtracting(Set(media)).forEach({
            context.delete($0)
        })
    }

}

// CDPhotoThread URLs
extension TeamMedia {

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
extension TeamMedia {

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
extension TeamMedia {

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
extension TeamMedia {

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
