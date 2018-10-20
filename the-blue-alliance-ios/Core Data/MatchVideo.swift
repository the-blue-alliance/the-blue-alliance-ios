import Foundation
import TBAKit
import CoreData

public enum MatchVideoType: String {
    case youtube = "youtube"
    case tba = "tba"
}

extension MatchVideo: Managed, Playable {

    var type: MatchVideoType? {
        guard let typeString = typeString else {
            return nil
        }
        return MatchVideoType(rawValue: typeString)
    }

    var youtubeKey: String? {
        if type == .youtube {
            return key
        }
        return nil
    }

    static func insert(with model: TBAMatchVideo, in context: NSManagedObjectContext) -> MatchVideo {
        let predicate = NSPredicate(format: "key == %@ AND typeString == %@", model.key, model.type)
        return findOrCreate(in: context, matching: predicate) { (matchVideo) in
            // Required: key, type
            matchVideo.key = model.key
            matchVideo.typeString = model.type
        }
    }

}
