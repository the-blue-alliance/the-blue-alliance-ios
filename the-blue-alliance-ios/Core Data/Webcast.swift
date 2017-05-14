//
//  Webcast.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/17/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

extension Webcast: Managed {
    
    static func insert(with model: TBAWebcast, for event: Event, in context: NSManagedObjectContext) -> Webcast {
        let predicate = NSPredicate(format: "event == %@ AND type == %@ AND channel == %@", event, model.type, model.channel)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return findOrCreate(in: context, matching: predicate, configure: { (webcast) in
            webcast.type = model.type
            webcast.channel = model.channel
            webcast.file = model.file
            
            if let dateString = model.date, let date = dateFormatter.date(from: dateString) {
                webcast.date = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
            }
            
            webcast.event = event
        })
    }
    
}
