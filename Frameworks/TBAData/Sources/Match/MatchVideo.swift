import CoreData
import Foundation
import TBAKit

@objc(MatchVideo)
public class MatchVideo: NSManagedObject {

    public var type: MatchVideoType? {
        guard let type = MatchVideoType(rawValue: typeString) else {
            return nil
        }
        return type
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchVideo> {
        return NSFetchRequest<MatchVideo>(entityName: "MatchVideo")
    }

    @NSManaged public fileprivate(set) var key: String
    @NSManaged private var typeString: String
    @NSManaged internal var matches: NSSet

}

// MARK: Generated accessors for matches
extension MatchVideo {

    @objc(addMatchesObject:)
    @NSManaged private func addToMatches(_ value: Match)

    @objc(removeMatchesObject:)
    @NSManaged internal func removeFromMatches(_ value: Match)

    @objc(addMatches:)
    @NSManaged private func addToMatches(_ values: NSSet)

    @objc(removeMatches:)
    @NSManaged private func removeFromMatches(_ values: NSSet)

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
                                    #keyPath(MatchVideo.key), model.key,
                                    #keyPath(MatchVideo.typeString), model.type)

        return findOrCreate(in: context, matching: predicate) { (matchVideo) in
            // Required: key, type
            matchVideo.key = model.key
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
