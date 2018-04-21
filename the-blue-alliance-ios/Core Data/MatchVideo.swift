import Foundation
import TBAKit
import CoreData

public enum MatchVideoType: String {
    case youtube = "youtube"
    case tba = "tba"
}

extension MatchVideo: Managed, Playable {
    
    var youtubeKey: String? {
        if type == MatchVideoType.youtube.rawValue {
            return key
        }
        return nil
    }
    
    static func insert(with model: TBAMatchVideo, for match: Match, in context: NSManagedObjectContext) -> MatchVideo {
        let predicate = NSPredicate(format: "key == %@ AND type == %@", model.key, model.type)
        return findOrCreate(in: context, matching: predicate) { (matchVideo) in
            // Required: key, type
            matchVideo.key = model.key
            matchVideo.type = model.type
            matchVideo.match = match
        }
    }
    
}
