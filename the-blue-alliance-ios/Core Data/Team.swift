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

extension Team {

    var homeChampionship: [String: String] {
        get {
            return homeChampionshipDictionary as? Dictionary<String, String> ?? [:]
        }
        set {
            homeChampionshipDictionary = newValue as NSDictionary
        }
    }
    
    var yearsParticipated: [Int] {
        get {
            let yearsArray = yearsParticipatedArray as? Array<Int> ?? []
            return yearsArray.sorted().reversed()
        }
        set {
            yearsParticipatedArray = newValue as NSArray
        }
    }
    
    static func insert(with model: TBATeam, in context: NSManagedObjectContext) throws -> Team {
        let predicate = NSPredicate(format: "key == %@", model.key)
        
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        let teams = try fetchRequest.execute()
        let team = teams.first ?? Team(context: context)
        
        // Required: key, name, teamNumber, rookieYear
        // TODO: Add in stuff that drops teams that don't have this info
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
        team.state = model.state
        team.teamNumber = Int32(model.teamNumber)
        team.website = model.website
        
        return team
    }

    static func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, [TBATeam]) -> (), completion: @escaping (Error?) -> ()) -> URLSessionDataTask {
        return fetchAllTeams(taskChanged: taskChanged, page: 0, completion: completion)
    }
    
    static private func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, [TBATeam]) -> (), page: Int, completion: @escaping (Error?) -> ()) -> URLSessionDataTask {
        return TBATeam.fetchTeams(page: page, completion: { (teams, error) in
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
