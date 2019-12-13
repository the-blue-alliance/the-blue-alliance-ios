import Foundation
import CoreData
import TBAKit

@objc(TeamMedia)
public class TeamMedia: NSManagedObject {

    public var type: MediaType? {
        guard let typeString = typeString else {
            fatalError("Save TeamMedia before accessing type")
        }
        guard let type = MediaType(rawValue: typeString) else {
            return nil
        }
        return type
    }

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

    public var preferred: Bool? {
        return preferredNumber?.boolValue
    }

    public var year: Int {
        guard let year = yearNumber?.intValue else {
            fatalError("Save TeamMedia before accessing year")
        }
        return year
    }

    public var team: Team {
        guard let team = teamOne else {
            fatalError("Save TeamMedia before accessing team")
        }
        return team
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMedia> {
        return NSFetchRequest<TeamMedia>(entityName: TeamMedia.entityName)
    }

    @NSManaged public private(set) var details: [String: Any]?
    @NSManaged public private(set) var directURL: String?
    @NSManaged public private(set) var foreignKey: String?
    @NSManaged private var mediaData: Data?
    @NSManaged private var mediaError: Error?
    @NSManaged private var preferredNumber: NSNumber?
    @NSManaged public private(set) var typeString: String?
    @NSManaged public private(set) var viewURL: String?
    @NSManaged private var yearNumber: NSNumber?
    @NSManaged private var teamOne: Team?

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
                                         #keyPath(TeamMedia.typeString), model.type)

        let yearPredicate = NSPredicate(format: "%K == %ld",
                                        #keyPath(TeamMedia.yearNumber), year)

        return findOrCreate(in: context, matching: NSCompoundPredicate(andPredicateWithSubpredicates: [mediaPredicate, yearPredicate])) { (media) in
            // Required: type, year, foreignKey
            media.typeString = model.type
            media.yearNumber = NSNumber(value: year)
            media.foreignKey = model.foreignKey
            media.details = model.details
            media.preferredNumber = NSNumber(value: model.preferred)
            media.viewURL = model.viewURL
            media.directURL = model.directURL
        }
    }

}

extension TeamMedia {

    public static func teamYearPrediate(teamKey: String, year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == %ld",
                           #keyPath(TeamMedia.teamOne.keyString), teamKey,
                           #keyPath(TeamMedia.yearNumber), year)
    }

    public static func teamYearImagesPrediate(teamKey: String, year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == %ld AND %K in %@",
                           #keyPath(TeamMedia.teamOne.keyString), teamKey,
                           #keyPath(TeamMedia.yearNumber), year,
                           #keyPath(TeamMedia.typeString), MediaType.imageTypes)
    }

    public static func nonePredicate(teamKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == nil",
                           #keyPath(TeamMedia.teamOne.keyString), teamKey,
                           #keyPath(TeamMedia.typeString))
    }

    public static func sortDescriptors() -> [NSSortDescriptor] {
        return [
            NSSortDescriptor(key: #keyPath(TeamMedia.typeString), ascending: false),
            NSSortDescriptor(key: #keyPath(TeamMedia.foreignKey), ascending: false)
        ]
    }

    public var imageDirectURL: URL? {
        guard let directURL = getValue(\TeamMedia.directURL) else {
            return nil
        }
        return URL(string: directURL)
    }

}

extension TeamMedia: Playable {

    public var youtubeKey: String? {
        if type == .youtubeVideo {
            return foreignKey
        }
        return nil
    }

}
