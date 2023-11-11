import CoreData
import Foundation
import TBAKit
import TBAProtocols
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
    case avatar = "avatar"
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

    public var details: [String: Any]? {
        return getValue(\TeamMedia.detailsRaw)
    }

    public var directURL: String? {
        return getValue(\TeamMedia.directURLRaw)
    }

    public var foreignKey: String {
        guard let foreignKey = getValue(\TeamMedia.foreignKeyRaw) else {
            fatalError("Save TeamMedia before accessing foreignKey")
        }
        return foreignKey
    }

    public var image: UIImage? {
        get {
            if let mediaData = getValue(\TeamMedia.mediaData) {
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
            return getValue(\TeamMedia.mediaError)
        }
        set {
            mediaError = newValue
            mediaData = nil
        }
    }

    public var preferred: Bool {
        guard let preferred = getValue(\TeamMedia.preferredRaw)?.boolValue else {
            fatalError("Save TeamMedia before accessing preferred")
        }
        return preferred
    }

    public var type: MediaType? {
        guard let typeString = getValue(\TeamMedia.typeStringRaw) else {
            fatalError("Save TeamMedia before accessing type")
        }
        guard let type = MediaType(rawValue: typeString) else {
            return nil
        }
        return type
    }

    public var viewURL: String? {
        return getValue(\TeamMedia.viewURLRaw)
    }

    public var year: Int {
        guard let year = getValue(\TeamMedia.yearRaw)?.intValue else {
            fatalError("Save TeamMedia before accessing year")
        }
        return year
    }

    public var team: Team {
        guard let team = getValue(\TeamMedia.teamRaw) else {
            fatalError("Save TeamMedia before accessing team")
        }
        return team
    }

}

@objc(TeamMedia)
public class TeamMedia: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMedia> {
        return NSFetchRequest<TeamMedia>(entityName: "TeamMedia")
    }

    @NSManaged var detailsRaw: [String: Any]?
    @NSManaged var directURLRaw: String?
    @NSManaged var foreignKeyRaw: String?
    @NSManaged var mediaData: Data?
    @NSManaged var mediaError: Error?
    @NSManaged var preferredRaw: NSNumber?
    @NSManaged var typeStringRaw: String?
    @NSManaged var viewURLRaw: String?
    @NSManaged var yearRaw: NSNumber?
    @NSManaged var teamRaw: Team?

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
        let mediaPredicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                         #keyPath(TeamMedia.foreignKeyRaw), model.foreignKey,
                                         #keyPath(TeamMedia.typeStringRaw), model.type)

        let yearPredicate = NSPredicate(format: "%K == %ld",
                                        #keyPath(TeamMedia.yearRaw), year)

        return findOrCreate(in: context, matching: NSCompoundPredicate(andPredicateWithSubpredicates: [mediaPredicate, yearPredicate])) { (media) in
            // Required: type, year, foreignKey
            media.typeStringRaw = model.type
            media.yearRaw = NSNumber(value: year)
            media.foreignKeyRaw = model.foreignKey
            media.detailsRaw = model.details
            media.preferredRaw = NSNumber(value: model.preferred)
            media.viewURLRaw = model.viewURL
            media.directURLRaw = model.directURL
        }
    }

}

extension TeamMedia {

    public static func teamYearPrediate(teamKey: String, year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == %ld",
                           #keyPath(TeamMedia.teamRaw.keyRaw), teamKey,
                           #keyPath(TeamMedia.yearRaw), year)
    }

    public static func teamYearImagesPrediate(teamKey: String, year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == %ld AND %K in %@",
                           #keyPath(TeamMedia.teamRaw.keyRaw), teamKey,
                           #keyPath(TeamMedia.yearRaw), year,
                           #keyPath(TeamMedia.typeStringRaw), MediaType.imageTypes)
    }

    public static func nonePredicate(teamKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == nil",
                           #keyPath(TeamMedia.teamRaw.keyRaw), teamKey,
                           #keyPath(TeamMedia.typeStringRaw))
    }

    public static func sortDescriptors() -> [NSSortDescriptor] {
        return [
            NSSortDescriptor(key: #keyPath(TeamMedia.typeStringRaw), ascending: false),
            NSSortDescriptor(key: #keyPath(TeamMedia.foreignKeyRaw), ascending: false)
        ]
    }

    public var imageDirectURL: URL? {
        guard let directURL = directURL else {
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

@objc(ErrorTransformer)
class ErrorTransformer: NSSecureUnarchiveFromDataTransformer {

    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSError.self]
    }

}
