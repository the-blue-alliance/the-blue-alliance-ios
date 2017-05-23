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
}

extension Media: Managed {
    
    static func insert(with model: TBAMedia, in context: NSManagedObjectContext) -> Media {
        let predicate = NSPredicate(format: "key == %@ AND type == %@", model.key, model.type)
        return findOrCreate(in: context, matching: predicate) { (media) in
            // Required: key, type
            media.key = model.key
            media.type = model.type
            media.foreignKey = model.foreignKey
            // TODO: details
            media.preferred = model.preferred ?? false
        }
    }

}
