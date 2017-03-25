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

public enum EventType: Int {
    case regional = 0
    case district = 1
    case districtChampionship = 2
    case championshipDivision = 3
    case championshipFinals = 4
    case offseason = 99
    case preseason = 100
    case unlabeled = -1
}

public enum EventTypeName: String {
    case regional = "Regional"
    case district = "District"
    case districtChampionship = "District Championship"
    case championshipDivision = "Championship Division"
    case championshipFinals = "Championship Finals"
    case offseason = "Offseason"
    case preseason = "Preseason"
    case unlabeled = "Unlabeled"
}

enum InitError: Error {
    case invalid(key: String)
}

extension Event {

    static func insert(with model: TBAEvent, in context: NSManagedObjectContext) throws -> Event {
        let predicate = NSPredicate(format: "key == %@", model.key)
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        let events = try fetchRequest.execute()
        let event = events.first ?? Event(context: context)
        
        // Required: endDate, eventCode, eventType, key, name, startDate, year
        event.address = model.address
        event.city = model.city
        event.country = model.country
        
        if let district = model.district {
            event.district = try? District.insert(with: district, in: context)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let endDate = dateFormatter.date(from: model.endDate) else {
            context.delete(event)
            throw InitError.invalid(key: "endDate")
        }
        
        event.endDate = NSDate(timeIntervalSince1970: endDate.timeIntervalSince1970)
        
        event.eventCode = model.eventCode
        event.eventType = Int16(model.eventType)
        event.eventTypeName = model.eventTypeName
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
        
        if let webcasts = model.webcasts {
            for modelWebcast in webcasts {
                _ = try? Webcast.insert(with: modelWebcast, for: event, in: context)
            }
        }
        
        event.website = model.website

        if let week = model.week {
            event.week = NSNumber(integerLiteral: week)
        }
        
        event.year = Int16(model.year)
                
        return event
    }
    
    // TODO: Move this somewhere else??
    public class func eventWeekString(eventOrder: EventOrder) -> String {
        let weekString: String?
        if eventOrder.type == EventType.districtChampionship.rawValue || eventOrder.type == EventType.championshipDivision.rawValue || eventOrder.type == EventType.championshipFinals.rawValue {
            // TODO: Need to handle different CMPs - "FIRST Championship - Houston" and "FIRST Championship - St. Louis"
            weekString = "Championship"
        } else {
            guard let week = eventOrder.week else {
                return "Other"
            }

            switch week {
            case EventType.unlabeled.rawValue:
                weekString = "Other"
            case EventType.preseason.rawValue:
                weekString = "Preseason"
            case EventType.districtChampionship.rawValue, EventType.championshipDivision.rawValue, EventType.championshipFinals.rawValue:
                weekString = "Championship"
            case EventType.offseason.rawValue:
                weekString = "Offseason"
            default:
                weekString = "Week \(week)"
            }
        }
        return weekString!
    }
    
    public func dateString() -> String? {
        if self.startDate == nil || self.endDate == nil {
            return nil
        }
        
        let calendar = Calendar.current
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MMM dd"
        
        let longDateFormatter = DateFormatter()
        longDateFormatter.dateFormat = "MMM dd, y"
        
        let startDate = Date(timeIntervalSince1970: self.startDate!.timeIntervalSince1970)
        let endDate = Date(timeIntervalSince1970: self.endDate!.timeIntervalSince1970)
        
        if let timezone = timezone {
            let tz = TimeZone(identifier: timezone)
            shortDateFormatter.timeZone = tz
            longDateFormatter.timeZone = tz
        }
        
        var dateText: String?
        if startDate == endDate {
            dateText = longDateFormatter.string(from: Date(timeIntervalSince1970: endDate.timeIntervalSince1970))
        } else if calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate) {
            dateText = "\(shortDateFormatter.string(from: startDate)) to \(shortDateFormatter.string(from: endDate))"
        } else {
            dateText = "\(longDateFormatter.string(from: startDate)) to \(longDateFormatter.string(from: endDate))"
        }
        
        return dateText
    }
    
}
