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

extension District: Managed {
    
    static func insert(with model: TBADistrict, in context: NSManagedObjectContext) -> District {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate, configure: { (district) in
            district.abbreviation = model.abbreviation
            district.name = model.name
            district.key = model.key
            
            if let year = model.year {
                district.year = Int16(year)
            }
        })
    }
    
}
