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
    
    var extraStats: [Int] {
        get {
            return extraStatsArray as? Array<Int> ?? []
        }
        set {
            extraStatsArray = newValue as NSArray
        }
    }
    
    var tieBreakers: [Double] {
        get {
            return tieBreakersArray as? Array<Double> ?? []
        }
        set {
            tieBreakersArray = newValue as NSArray
        }
    }
    
    static func insert(with model: TBAEventRanking, for event: Event, for team: Team, in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "event == %@ AND team == %@", event, team)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.event = event
            ranking.team = team
            
            if let qualAverage = model.qualAverage {
                ranking.qualAverage = NSNumber(value: qualAverage)
            }
            
            ranking.rank = Int16(model.rank)
            
            if let wins = model.record?.wins {
                ranking.wins = wins as NSNumber
            }
            
            if let ties = model.record?.ties {
                ranking.ties = ties as NSNumber
            }
            
            if let losses = model.record?.losses {
                ranking.losses = losses as NSNumber
            }
            
            if let dq = model.dq {
                ranking.dq = dq as NSNumber
            }
            
            if let matchesPlayed = model.matchesPlayed {
                ranking.matchesPlayed = matchesPlayed as NSNumber
            }
            
            if let extraStats = model.extraStats, !extraStats.isEmpty {
                ranking.extraStats = extraStats
            }
            
            if let tieBreakers = model.sortOrders, !tieBreakers.isEmpty {
                ranking.tieBreakers = tieBreakers
            }
        })
    }
}
