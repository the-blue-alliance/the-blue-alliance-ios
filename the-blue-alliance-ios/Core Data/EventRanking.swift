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
    
    var sortOrderInfoNames: [String] {
        get {
            return sortOrderInfoNamesArray as? Array<String> ?? []
        }
        set {
            sortOrderInfoNamesArray = newValue as NSArray
        }
    }
    
    var infoString: String? {
        get {
            if !tieBreakers.isEmpty && !sortOrderInfoNames.isEmpty && tieBreakers.count == sortOrderInfoNames.count {
                var string = ""
                for (sortOrderName, sortOrderValue) in zip(sortOrderInfoNames, tieBreakers) {
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
            
            if let tieBreakers = model.sortOrders, !tieBreakers.isEmpty {
                ranking.tieBreakers = tieBreakers
            }
            
            let sortOrderInfoNames = sortOrderInfo.map { $0.name }
            if !sortOrderInfoNames.isEmpty {
                ranking.sortOrderInfoNames = sortOrderInfoNames
            }
        })
    }
}
