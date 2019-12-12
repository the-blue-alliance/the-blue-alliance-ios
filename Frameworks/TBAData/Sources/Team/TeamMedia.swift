import Foundation
import CoreData
import TBAKit

@objc(TeamMedia)
public class TeamMedia: NSManagedObject {

    public var image: UIImage? {
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

    public var imageError: Error? {
        get {
            return mediaError
        }
        set {
            mediaError = newValue
            mediaData = nil
        }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMedia> {
        return NSFetchRequest<TeamMedia>(entityName: "TeamMedia")
    }

    @NSManaged public fileprivate(set) var details: [String: Any]?
    @NSManaged public fileprivate(set) var directURL: String?
    @NSManaged public fileprivate(set) var foreignKey: String
    @NSManaged private var mediaData: Data?
    @NSManaged private var mediaError: Error?
    @NSManaged public fileprivate(set) var preferred: Bool
    @NSManaged public fileprivate(set) var type: String
    @NSManaged public fileprivate(set) var viewURL: String?
    @NSManaged public fileprivate(set) var year: Int16
    @NSManaged public fileprivate(set) var team: Team

}

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

extension TeamMedia: Managed {

    /**
     Insert a Team Media with values from a TBAKit Media model in to the managed object context.

     - Parameter model: The TBAKit Team representation to set values from.

     - Parameter year: The year the Team Media relates to.

     - Parameter context: The NSManagedContext to insert the Team Media in to.

     - Returns: The inserted Team Media.
     */
    @discardableResult
    public static func insert(_ model: TBAMedia, year: Int, in context: NSManagedObjectContext) -> TeamMedia {
        var mediaPredicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                         #keyPath(TeamMedia.foreignKey), model.foreignKey,
                                         #keyPath(TeamMedia.type), model.type)

        let yearPredicate = NSPredicate(format: "%K == %ld",
                                        #keyPath(TeamMedia.year), year)

        return findOrCreate(in: context, matching: NSCompoundPredicate(andPredicateWithSubpredicates: [mediaPredicate, yearPredicate])) { (media) in
            // Required: type, year, foreignKey
            media.type = model.type
            media.year = Int16(year)
            media.foreignKey = model.foreignKey
            media.details = model.details
            media.preferred = model.preferred ?? false
            media.viewURL = model.viewURL
            media.directURL = model.directURL
        }
    }

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
