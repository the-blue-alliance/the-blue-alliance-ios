//
//  EventPoints.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/4/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import CoreData
import TBAKit

extension EventPoints: Managed {
    
    static func insert(with model: TBADistrictEventPoints, for event: Event, in context: NSManagedObjectContext) -> EventPoints {
        guard let teamKey = model.teamKey else {
            fatalError("Need team key")
        }
        
        var team = Team.findOrFetch(in: context, matching: NSPredicate(format: "key == %@", teamKey))
        if team == nil {
            team = Team.insert(with: teamKey, in: context)
        }
        
        return insert(with: model, for: event, and: team!, in: context)
    }
    
    static func insert(with model: TBADistrictEventPoints, for event: Event, and team: Team, in context: NSManagedObjectContext) -> EventPoints {
        let predicate = NSPredicate(format: "team == %@ AND event == %@", team, event)
        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.team = team
            eventPoints.event = event
            
            eventPoints.alliancePoints = Int16(model.alliancePoints)
            eventPoints.awardPoints = Int16(model.awardPoints)
            
            if let districtCMP = model.districtCMP {
                eventPoints.districtCMP = NSNumber(booleanLiteral: districtCMP)
            }
            
            eventPoints.elimPoints = Int16(model.elimPoints)
            eventPoints.qualPoints = Int16(model.qualPoints)
            eventPoints.total = Int16(model.total)
        }
    }

}
