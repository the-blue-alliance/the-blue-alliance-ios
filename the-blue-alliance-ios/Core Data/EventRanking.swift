//
//  EventRanking.swift
//  the-blue-alliance-ios
//
//  Created by Bryton Moeller on 6/1/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

extension EventRanking: Managed {
    
    static func insert(with model: TBAEventRanking, for event: Event, for team: Team, in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "event == %@ AND team == %@", event, team)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.event = event
            ranking.team = team
            if let qualAverage = model.qualAverage {
                ranking.qualAverage = qualAverage
            }
            ranking.rank = Int16(model.rank)
            ranking.record = model.record as NSObject
            ranking.tieBreakers = model.tieBreakers as NSObject
            
            
        })
    }
    
}
