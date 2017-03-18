//
//  District.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/13/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

extension District {
    
    public enum DistrictTypeName: String {
        case Michigan = "Michigan"
        case MidAtlantic = "Mid-Atlantic"
        case NewEngland = "New England"
        case PacificNorthwest = "Pacific Northwest"
        case Indiana = "Indiana"
        case Chesapeake = "Chesapeake"
        case NorthCarolina = "North Carolina"
        case Georgia = "Georgia"
        case Ontario = "Ontario"
        case Israel = "Israel"
    }
    
    static func insert(with model: TBADistrict, in context: NSManagedObjectContext) throws -> District {
        let predicate = NSPredicate(format: "key == %@", model.key)
        
        let fetchRequest: NSFetchRequest<District> = District.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        let distrcits = try fetchRequest.execute()
        let district = distrcits.first ?? District(context: context)
        
        district.abbreviation = model.abbreviation
        district.name = model.name
        district.key = model.key
        
        if let year = model.year {
            district.year = Int16(year)
        }
        
        return district
    }
    
}
