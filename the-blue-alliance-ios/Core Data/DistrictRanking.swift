//
//  DistrictRanking.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

extension DistrictRanking: Managed {
    
    static func insert(with model: TBADistrictRanking, for district: District, for team: Team, in context: NSManagedObjectContext) -> DistrictRanking {
        let predicate = NSPredicate(format: "district == %@ AND team == %@", district, team)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.district = district
            ranking.team = team
            
            ranking.pointTotal = Int16(model.pointTotal)
            ranking.rank = Int16(model.rank)
            
            if let rookieBonus = model.rookieBonus {
                ranking.rookieBonus = Int16(rookieBonus)
            }
            
            ranking.eventPoints = Set(model.eventPoints.compactMap({ (modelPoints) -> DistrictEventPoints? in
                guard let eventKey = modelPoints.eventKey else {
                    return nil
                }
                
                let eventPredicate = NSPredicate(format: "key == %@", eventKey)
                guard let event = Event.findOrFetch(in: context, matching: eventPredicate) else {
                    return nil
                }

                return DistrictEventPoints.insert(with: modelPoints, for: event, and: team, in: context)
            })) as NSSet
        })
    }
    
}
