//
//  Media.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

public enum MediaType: String {
    case youtubeVideo = "youtube"
    case cdPhotoThread = "cdphotothread"
    case imgur = "imgur"
    case facebook = "facebook-profile"
    case youtube = "youtube-channel"
    case twitter = "twitter-profile"
    case github = "github-profile"
    case instagram = "instagram-profile"
    case periscope = "periscope-profile"
    case grabcad = "grabcad"
    case pinterest = "pinterest-profile"
    case snapchat = "snapchat-profile"
    case twitch = "twitch-channel"
    case instagramImage = "instagram-image"
}

extension Media: Managed {
    
    var details: [String: Any]? {
        get {
            return detailsDictionary as? Dictionary<String, Any> ?? [:]
        }
        set {
            detailsDictionary = newValue as NSDictionary?
        }
    }
    
    static func insert(with model: TBAMedia, for year: Int, in context: NSManagedObjectContext) -> Media {
        var mediaPredicate: NSPredicate?
        if let key = model.key {
            mediaPredicate = NSPredicate(format: "key == %@ AND type == %@", key, model.type)
        } else if let foreignKey = model.foreignKey {
            mediaPredicate = NSPredicate(format: "foreignKey == %@ AND type == %@", foreignKey, model.type)
        }
        guard let predicate = mediaPredicate else {
            fatalError("No way to filter media")
        }
        return findOrCreate(in: context, matching: predicate) { (media) in
            // Required: type, year
            media.key = model.key
            media.type = model.type
            media.year = Int16(year)
            media.foreignKey = model.foreignKey
            media.details = model.details
            media.preferred = model.preferred ?? false
        }
    }

}
