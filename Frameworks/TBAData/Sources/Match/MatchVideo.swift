import CoreData
import Foundation
import TBAKit

@objc(MatchVideo)
public class MatchVideo: NSManagedObject {

    public var key: String {
        guard let key = keyString else {
            fatalError("Save MatchVideo before accessing key")
        }
        return key
    }

    public var type: MatchVideoType? {
        guard let typeString = typeString else {
            fatalError("Save MatchVideo before accessing type")
        }
        guard let type = MatchVideoType(rawValue: typeString) else {
            return nil
        }
        return type
    }

    public var matches: [Match] {
        guard let matchesMany = matchesMany, let matches = matchesMany.allObjects as? [Match] else {
            return []
        }
        return matches
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchVideo> {
        return NSFetchRequest<MatchVideo>(entityName: MatchVideo.entityName)
    }

    @NSManaged private var keyString: String?
    @NSManaged private var typeString: String?
    @NSManaged private var matchesMany: NSSet?

}

// MARK: Generated accessors for matches
extension MatchVideo {

    @objc(removeMatchesObject:)
    @NSManaged internal func removeFromMatchesMany(_ value: Match)

}

public enum MatchVideoType: String {
    case youtube = "youtube"
    case tba = "tba"
}

extension MatchVideo: Managed {

    /**
     Insert a Match Video with values from a TBAKit Match Video model in to the managed object context.

     - Important: This method does not manage setting up a Match Video's relationship to a Match.

     - Parameter model: The TBAKit Match Video representation to set values from.

     - Parameter context: The NSManagedContext to insert the Match Video in to.

     - Returns: The inserted Match Video.
     */
    public static func insert(_ model: TBAMatchVideo, in context: NSManagedObjectContext) -> MatchVideo {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(MatchVideo.keyString), model.key,
                                    #keyPath(MatchVideo.typeString), model.type)

        return findOrCreate(in: context, matching: predicate) { (matchVideo) in
            // Required: key, type
            matchVideo.keyString = model.key
            matchVideo.typeString = model.type
        }
    }

}

extension MatchVideo: Playable {

    public var youtubeKey: String? {
        if type == .youtube {
            return key
        }
        return nil
    }

}

extension MatchVideo: Orphanable {

    public var isOrphaned: Bool {
        return matches.count == 0
    }

}
