import CoreData
import Foundation
import TBAKit
import TBAProtocols

extension MatchVideo {

    public var key: String {
        guard let key = getValue(\MatchVideo.keyRaw) else {
            fatalError("Save MatchVideo before accessing key")
        }
        return key
    }

    public var type: MatchVideoType? {
        guard let typeString = getValue(\MatchVideo.typeRaw) else {
            fatalError("Save MatchVideo before accessing type")
        }
        guard let type = MatchVideoType(rawValue: typeString) else {
            return nil
        }
        return type
    }

    public var matches: [Match] {
        guard let matchesRaw = getValue(\MatchVideo.matchesRaw),
            let matches = matchesRaw.allObjects as? [Match] else {
                return []
        }
        return matches
    }

}

@objc(MatchVideo)
public class MatchVideo: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchVideo> {
        return NSFetchRequest<MatchVideo>(entityName: MatchVideo.entityName)
    }

    @NSManaged var keyRaw: String?
    @NSManaged var typeRaw: String?
    @NSManaged var matchesRaw: NSSet?

}

// MARK: Generated accessors for matchesRaw
extension MatchVideo {

    @objc(addMatchesRawObject:)
    @NSManaged func addToMatchesRaw(_ value: Match)

    @objc(removeMatchesRawObject:)
    @NSManaged func removeFromMatchesRaw(_ value: Match)

    @objc(addMatchesRaw:)
    @NSManaged func addToMatchesRaw(_ values: NSSet)

    @objc(removeMatchesRaw:)
    @NSManaged func removeFromMatchesRaw(_ values: NSSet)

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
                                    #keyPath(MatchVideo.keyRaw), model.key,
                                    #keyPath(MatchVideo.typeRaw), model.type)

        return findOrCreate(in: context, matching: predicate) { (matchVideo) in
            // Required: key, type
            matchVideo.keyRaw = model.key
            matchVideo.typeRaw = model.type
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
