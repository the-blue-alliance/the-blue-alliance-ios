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
    
    var tieBreakerValues: [Double] {
        get {
            return tieBreakerValuesArray as? Array<Double> ?? []
        }
        set {
            tieBreakerValuesArray = newValue as NSArray
        }
    }
    
    var tieBreakerNames: [String] {
        get {
            return tieBreakerNamesArray as? Array<String> ?? []
        }
        set {
            tieBreakerNamesArray = newValue as NSArray
        }
    }
    
    var infoString: String? {
        get {
            if !tieBreakerValues.isEmpty, !tieBreakerNames.isEmpty {
                var string = ""
                for (sortOrderName, sortOrderValue) in zip(tieBreakerNames, tieBreakerValues) {
                    string.append("\(sortOrderName): \(sortOrderValue), ")
                }
                
                // To remove the trailing comma and space
                string.remove(at: string.index(before: string.endIndex))
                string.remove(at: string.index(before: string.endIndex))
                
                return string
            }
            return nil
        }
    }
    
    static func insert(with model: TBAEventRanking, for event: Event, for team: Team, for sortOrderInfo: [TBAEventRankingSortOrder], in context: NSManagedObjectContext) -> EventRanking {
        let predicate = NSPredicate(format: "event == %@ AND team == %@", event, team)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.event = event
            ranking.team = team
            
            if let qualAverage = model.qualAverage {
                ranking.qualAverage = NSNumber(value: qualAverage)
            }
            
            ranking.rank = Int16(model.rank)
            
            if let wins = model.record?.wins {
                ranking.wins = NSNumber(value: wins)
            }
            
            if let ties = model.record?.ties {
                ranking.ties = NSNumber(value: ties)
            }
            
            if let losses = model.record?.losses {
                ranking.losses = NSNumber(value: losses)
            }
            
            if let dq = model.dq {
                ranking.dq = NSNumber(value: dq)
            }
            
            if let matchesPlayed = model.matchesPlayed {
                ranking.matchesPlayed = NSNumber(value: matchesPlayed)
            }
            
            if let extraStats = model.extraStats, !extraStats.isEmpty {
                ranking.extraStats = extraStats
            }
            
            if let tieBreakerValues = model.sortOrders, !tieBreakerValues.isEmpty {
                ranking.tieBreakerValues = tieBreakerValues
            }
            
            let tieBreakerNames = sortOrderInfo.map { $0.name }
            if !tieBreakerNames.isEmpty {
                ranking.tieBreakerNames = tieBreakerNames
            }
        })
    }
}
