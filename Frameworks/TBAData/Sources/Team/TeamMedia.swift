import Foundation
import CoreData
import TBAKit

@objc(TeamMedia)
public class TeamMedia: NSManagedObject {

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

extension TeamMedia {

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
