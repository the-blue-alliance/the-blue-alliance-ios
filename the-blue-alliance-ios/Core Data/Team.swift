//
//  Team.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/12/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

extension Team: Locatable, Managed {
        
    var fallbackNickname: String {
        return "Team \(teamNumber)"
    }
    
    static func insert(with key: String, in context: NSManagedObjectContext) -> Team {
        let predicate = NSPredicate(format: "key == %@", key)
        // Let's not *overwrite* shit we already have
        if let team = findOrFetch(in: context, matching: predicate) {
            return team
        }
        return findOrCreate(in: context, matching: predicate) { (team) in
            // Required: key, name, teamNumber
            team.key = key
            
            let teamNumber = Int32(key.prefixTrim("frc"))!
            team.name = "Team \(teamNumber)"
            team.teamNumber = teamNumber
        }
    }
    
    static func insert(with model: TBATeam, in context: NSManagedObjectContext) -> Team {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate) { (team) in
            // Required: key, name, teamNumber, rookieYear
            team.address = model.address
            team.city = model.city
            team.country = model.country
            team.gmapsPlaceID = model.gmapsPlaceID
            team.gmapsURL = model.gmapsURL
            
            if let homeChampionship = model.homeChampionship {
                team.homeChampionship = homeChampionship
            }
            
            team.key = model.key
            
            if let lat = model.lat {
                team.lat = NSNumber(value: lat)
            }
            if let lng = model.lng {
                team.lng = NSNumber(value: lng)
            }
            
            team.locationName = model.locationName
            team.motto = model.motto
            team.name = model.name
            team.nickname = model.nickname
            team.postalCode = model.postalCode
            team.rookieYear = Int16(model.rookieYear)
            team.stateProv = model.stateProv
            team.teamNumber = Int32(model.teamNumber)
            team.website = model.website
            team.homeChampionship = model.homeChampionship
        }
    }
    
    static func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, [TBATeam]) -> (), completion: @escaping (Error?) -> ()) -> URLSessionDataTask {
        return fetchAllTeams(taskChanged: taskChanged, page: 0, completion: completion)
    }
    
    static private func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, [TBATeam]) -> (), page: Int, completion: @escaping (Error?) -> ()) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchTeams(page: page, completion: { (teams, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let teams = teams else {
                completion(APIError.error("No teams for page \(page)"))
                return
            }
            
            if teams.isEmpty {
                completion(nil)
            } else {
                taskChanged(self.fetchAllTeams(taskChanged: taskChanged, page: page + 1, completion: completion), teams)
            }
        })
    }
    
}
