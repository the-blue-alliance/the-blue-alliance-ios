//
//  Event.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/7/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import CoreData

enum EventWeek: Int {
    case unlabeled = -1
    case preseason = 0
    case championship = 99
    case offseason = 100
}

enum InitError: Error {
    case invalid(key: String)
}

extension Event {

    static func insert(with model: TBAEvent, in context: NSManagedObjectContext) throws {
        let predicate = NSPredicate(format: "key == %@", model.key)
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        let events = try fetchRequest.execute()
        let event = events.first ?? Event(context: context)
        
        // Setup event variables here
        event.address = model.address
        event.city = model.city
        event.country = model.country
        event.districtType = Int16(model.districtType.rawValue)
        event.districtTypeName = model.districtTypeName?.rawValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let endDate = dateFormatter.date(from: model.endDate) else {
            context.delete(event)
            throw InitError.invalid(key: "endDate")
        }
        
        event.endDate = NSDate(timeIntervalSince1970: endDate.timeIntervalSince1970)
        
        event.eventCode = model.eventCode
        event.eventType = Int16(model.eventType.rawValue)
        event.eventTypeName = model.eventTypeName.rawValue
        event.firstEventID = model.firstEventID
        event.gmapsPlaceID = model.gmapsPlaceID
        event.gmapsURL = model.gmapsURL
        event.key = model.key
        
        if let lat = model.lat {
            event.lat = NSNumber(value: lat)
        }
        if let lng = model.lng {
            event.lng = NSNumber(value: lng)
        }
        
        event.locationName = model.locationName
        event.name = model.name
        event.postalCode = model.postalCode
        event.shortName = model.shortName
        
        guard let startDate = dateFormatter.date(from: model.startDate) else {
            context.delete(event)
            throw InitError.invalid(key: "startDate")
        }
        event.startDate = NSDate(timeIntervalSince1970: startDate.timeIntervalSince1970)
        
        event.state = model.state
        event.timezone = model.timezone
        
        // TODO: webcasts
        
        event.website = model.website
        
        if let week = model.week {
            event.week = Int16(week)
        } else {
            switch model.eventType {
            case .unlabeled:
                event.week = Int16(EventWeek.unlabeled.rawValue)
            case .preseason:
                event.week = Int16(EventWeek.preseason.rawValue)
            case .districtChampionship, .championshipDivision, .championshipFinals:
                event.week = Int16(EventWeek.championship.rawValue)
            case .offseason:
                event.week = Int16(EventWeek.offseason.rawValue)
            default:
                context.delete(event)
                throw InitError.invalid(key: "week")
            }
        }
        
        event.year = Int16(model.year)
        
        // Will sort high level events in order
        // Preseason < Regionals < Districts (MI, MAR, NE, PNW, IN), CMP Divisions, CMP Finals, Offseason, others
        // Will then sub-divide districts in to floats
        // ex: Michigan Districts: 1.1, Indiana Districts: 1.5
        let isDistrict = (Int(event.districtType) != TBAEvent.DistrictType.NoDistrict.rawValue && Int(event.eventType) != TBAEvent.EventType.districtChampionship.rawValue)
        event.hybridType = isDistrict ? Float(event.eventType) + (Float(event.districtType) / 10.0) : Float(event.eventType)
    }

    // MARK: - Helper Methods
    
    func isDistrict() -> Bool {
        return self.districtType != Int16(TBAEvent.DistrictType.NoDistrict.rawValue)
    }
    
}
