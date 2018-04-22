//
//  Match.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

public enum MatchCompLevel: String {
    case qualification = "qm"
    case eightfinal = "ef"
    case quarterfinal = "qf"
    case semifinal = "sf"
    case final = "f"
    
    var intVal: Int16 {
        switch self {
        case .qualification:
            return 0
        case .eightfinal:
            return 1
        case .quarterfinal:
            return 2
        case .semifinal:
            return 3
        case .final:
            return 4
        }
    }
}

extension Match: Managed {

    var redBreakdown: [String: Any]? {
        get {
            return redBreakdownDictionary as? Dictionary<String, Any> ?? [:]
        }
        set {
            redBreakdownDictionary = newValue as NSDictionary?
        }
    }
    
    var blueBreakdown: [String: Any]? {
        get {
            return blueBreakdownDictionary as? Dictionary<String, Any> ?? [:]
        }
        set {
            blueBreakdownDictionary = newValue as NSDictionary?
        }
    }
    
    var compLevelString: String {
        guard let compLevel = compLevel else {
            return ""
        }
        switch compLevel {
        case MatchCompLevel.qualification.rawValue:
            return "Qualification"
        case MatchCompLevel.eightfinal.rawValue:
            return "Octofinal"
        case MatchCompLevel.quarterfinal.rawValue:
            return "Quarterfinal"
        case MatchCompLevel.semifinal.rawValue:
            return "Semifinal"
        case MatchCompLevel.final.rawValue:
            return "Finals"
        default:
            return ""
        }
    }

    var shortCompLevelString: String {
        guard let compLevel = compLevel else {
            return ""
        }
        switch compLevel {
        case MatchCompLevel.qualification.rawValue:
            return "Qual"
        case MatchCompLevel.eightfinal.rawValue:
            return "Octofinal"
        case MatchCompLevel.quarterfinal.rawValue:
            return "Quarter"
        case MatchCompLevel.semifinal.rawValue:
            return "Semi"
        case MatchCompLevel.final.rawValue:
            return "Final"
        default:
            return ""
        }
    }
    
    var timeString: String? {
        guard let time = time else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE h:mm a"
        
        let date = Date(timeIntervalSince1970: time.doubleValue)
        return dateFormatter.string(from: date)
    }
    
    static func insert(with model: TBAMatch, for event: Event, in context: NSManagedObjectContext) -> Match {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate) { (match) in
            // Required: compLevel, eventKey, key, matchNumber, setNumber
            match.key = model.key
            match.compLevel = model.compLevel
            
            let compLevelStruct = MatchCompLevel(rawValue: match.compLevel!)
            match.compLevelInt = compLevelStruct!.intVal
            
            match.setNumber = Int16(model.setNumber)
            match.matchNumber = Int16(model.matchNumber)
            
            if let redAlliance = model.redAlliance {
                match.redAlliance = Set(redAlliance.teams.map({ (teamKey) -> Team in
                    var team = Team.findOrFetch(in: context, matching: NSPredicate(format: "key == %@", teamKey))
                    if team == nil {
                        team = Team.insert(with: teamKey, in: context)
                    }
                    return team!
                })) as NSSet
                match.redScore = NSNumber(value: redAlliance.score)
                // TODO: add surrogate teams
            }
            
            if let blueAlliance = model.blueAlliance {
                match.blueAlliance = Set(blueAlliance.teams.map({ (teamKey) -> Team in
                    var team = Team.findOrFetch(in: context, matching: NSPredicate(format: "key == %@", teamKey))
                    if team == nil {
                        team = Team.insert(with: teamKey, in: context)
                    }
                    return team!
                })) as NSSet
                match.blueScore = NSNumber(value: blueAlliance.score)
                // TODO: add surrogate teams
            }
            
            match.winningAlliance = model.winningAlliance
            match.event = event
            if let time = model.time {
                match.time = NSNumber(value: time)
            }
            if let actualTime = model.actualTime {
                match.actualTime = NSNumber(value: actualTime)
            }
            if let predictedTime = model.predictedTime {
                match.predictedTime = NSNumber(value: predictedTime)
            }
            if let postResultTime = model.postResultTime {
                match.postResultTime = NSNumber(value: postResultTime)
            }
            
            match.redBreakdown = model.redBreakdown
            match.blueBreakdown = model.blueBreakdown
            
            if let videos = model.videos {
                match.videos = Set(videos.map({ (modelVideo) -> Media in
                    return Media.insert(with: modelVideo, for: Int(event.year), in: context)
                })) as NSSet
            }
        }
    }

    public func friendlyMatchName() -> String {
        guard let compLevel = compLevel else {
            return ""
        }
        
        let matchName = shortCompLevelString
        
        switch compLevel {
        case MatchCompLevel.qualification.rawValue:
            return "\(matchName) \(matchNumber)"
        case MatchCompLevel.eightfinal.rawValue,
             MatchCompLevel.quarterfinal.rawValue,
             MatchCompLevel.semifinal.rawValue,
             MatchCompLevel.final.rawValue:
            return "\(matchName) \(setNumber) - \(matchNumber)"

        default:
            return matchName
        }
    }
    
}
