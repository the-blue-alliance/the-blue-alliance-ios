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

extension Webcast {
    
    static func insert(with model: TBAWebcast, for event: Event, in context: NSManagedObjectContext) throws -> Webcast {
        let predicate = NSPredicate(format: "event == %@ AND type == %@ AND channel == %@", event, model.type, model.channel)

        let fetchRequest: NSFetchRequest<Webcast> = Webcast.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        let webcasts = try fetchRequest.execute()
        let webcast = webcasts.first ?? Webcast(context: context)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Setup event variables here
        webcast.type = model.type
        webcast.channel = model.channel
        webcast.file = model.file
        
        guard let dateString = model.date, let date = dateFormatter.date(from: dateString) else {
            context.delete(webcast)
            throw InitError.invalid(key: "date")
        }
        webcast.date = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        
        webcast.event = event
        
        return webcast
    }
    
}
