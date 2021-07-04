//
//  TBADataError.swift
//  
//
//  Created by Zachary Orr on 6/14/21.
//

import Foundation

public enum TBADataError: Error {
    case missingManagedObjectContext
    case wrongObjectType
    case missingKeyPathValue(String)
}
