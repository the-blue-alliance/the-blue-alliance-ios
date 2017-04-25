//
//  EventsContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/18/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TBAKit

let EventsEmbed = "EventsEmbed"
let EventSegue = "EventSegue"
let SelectWeekSegue = "SelectWeekSegue"
let SelectYearSegue = "SelectYearSegue"

// Dear Zach... you just finished creating the EventOrder struct and using it internally for modeling this VC
// This is an okay idea I suppose - you have these "abstract" ideas of types/weeks which you can use to setup
// different labels and pull proper data and whatnot. Think about making it so EventOrder (or a better name) is
// a function (or a transient propery?) on an Event object, and you just fetch all and pull that property from
// events. That way you're not constantly assembling structs all over the fucking place based on data you pull
// from Core Data.
// 
// Additionally, you'll need to refactor that NumberSelectViewController to use generics... it no longer takes
// only a number, it takes a series of things. You should be able to figure something out.
//
// xoxo
// 1:07am Zach

public struct EventOrder: Equatable, Comparable, Hashable, CustomStringConvertible {
    public var type: Int
    public var week: Int?
    public var year: Int
    
    public init(type: Int, week: Int?, year: Int) {
        self.type = type
        self.week = week
        self.year = year
    }
    
    // MARK: Equatable
    
    public static func ==(lhs: EventOrder, rhs: EventOrder) -> Bool {
        return (lhs.type == rhs.type) && (lhs.week == rhs.week) && (lhs.year == rhs.year)
    }
    
    // MARK: Comparable
    
    // In order... Preseason, Week 1, Week 2, ..., Week 7, CMP, Offseason, Unlabeled
    // (type: 100, week: nil) < (type: 0, week: 1)
    // (type: 99, week: nil) < (type: -1, week: nil)
    
    public static func <(lhs: EventOrder, rhs: EventOrder) -> Bool {
        // Events with earlier years are always first
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        // Preseason events should always come first
        if lhs.type == EventType.preseason.rawValue || rhs.type == EventType.preseason.rawValue {
            return lhs.type < rhs.type
        }
        return false
    }
    
    // MARK: Hashable
    
    public var hashValue : Int {
        get {
            var weekString = "nil"
            if let week = week {
                weekString = "\(week)"
            }
            return "\(self.type),\(weekString),\(self.year)".hashValue
        }
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        var weekString = "nil"
        if let week = week {
            weekString = "\(week)"
        }
        return "Type: \(self.type) | Week: \(weekString) | Year: \(self.year)"
    }
    
}

class EventsContainerViewController: TBAViewController {
    internal var eventsViewController: EventsTableViewController?
    @IBOutlet internal var eventsView: UIView?
    @IBOutlet internal var weeksButton: UIBarButtonItem?
    
    internal var weeks: [EventOrder]?
    internal var maxYear: Int?
    internal var week: EventOrder? {
        didSet {
            print("Set week")
            eventsViewController?.week = week?.week

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    internal var year: Int? {
        didSet {
            print("Set year")
            eventsViewController?.year = year
            
            // Only setup weeks again if we've changed years
            if week?.year != year {
                setupWeeks()
            }
            
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        let year = UserDefaults.standard.integer(forKey: StatusConstants.currentSeasonKey)
        if year != 0 {
            self.year = year
        }
        
        let maxYear = UserDefaults.standard.integer(forKey: StatusConstants.maxSeasonKey)
        if maxYear != 0 {
            self.maxYear = maxYear
        }
        
        super.init(coder: aDecoder)
        print("Initilized")
    }
    
    override func viewDidLoad() {
        print("View loaded")
        super.viewDidLoad()
        
        viewControllers = [eventsViewController!]
        containerViews = [eventsView!]
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fetchedTBAStatus),
                                               name: Notification.Name(kFetchedTBAStatus),
                                               object: nil)
        
        // TODO: Sometimes this gets called twice...
        if year != nil {
            setupWeeks()
        }
        
        updateInterface()
    }
    
    // MARK: - Private Methods

    func updateInterface() {
        print("Updating interface")
        if let week = week {
            navigationTitleLabel?.text = "\(Event.eventWeekString(eventOrder: week)) Events"
        } else {
            navigationTitleLabel?.text = "---- Events"
        }
        
        if let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
        
        if weeks != nil {
            weeksButton?.title = "Weeks"
        } else {
            weeksButton?.title = "----"
        }
        
        if year == nil && week == nil {
            // Show loading
        } else {
            // Hide loading
        }
    }
    
    func setupCurrentSeasonWeek() {
        print("Setting up current season week")
        guard let year = year else {
            // TOOD: Show no year state
            return
        }

        // Fetch all events where endDate is today or after today
        let date = NSDate()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "year == %ld && endDate >= %@", year, date)
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        fetchRequest.propertiesToFetch = ["startDate", "endDate", "week", "eventType"].map({ (propertyName) -> NSPropertyDescription in
            return Event.entity().propertiesByName[propertyName]!
        })
        
        guard let eventDates = try? persistentContainer?.viewContext.fetch(fetchRequest) as! [[String: Any]] else {
            // TODO: Throw init error
            return
        }
        
        // TODO: Need to know if we have no events OR if we just don't have any more events this year
        // TODO: CMP is handled differently
        if let dateDict = eventDates.first, let type = dateDict["eventType"] as? NSNumber, let week = dateDict["week"] as? NSNumber {
            self.week = EventOrder(type: type.intValue, week: week.intValue, year: year)
        } else {
            // TODO: Show some error here
        }
    }
    
    func setupWeeks() {
        print("Setting up weeks")
        guard let year = year else {
            // TOOD: Show no year state
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "year == %ld", year)
        // TODO: We need to change these sorts but it should be fine
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true), NSSortDescriptor(key: "eventType", ascending: true)]
        
        guard let events = try? persistentContainer?.viewContext.fetch(fetchRequest) as! [Event] else {
            // TODO: Unable to fetch events
            return
        }
        // TODO: Need to know if we have no events OR if we just don't have any more events this year
        // TODO: CMP is handled differently
        if events.count == 0 {
            guard let eventsViewController = eventsViewController else {
                // TODO: Show error here, or we could always call again once we set this VC
                return
            }
            // Initial load of events for eventsVC
            eventsViewController.refresh()
            return
        }

        self.weeks = Array(Set(events.map({ (e) -> EventOrder in
            return EventOrder(type: Int(e.eventType), week: e.week?.intValue, year: year)
        }))).sorted()
        print(self.weeks!)
        
        if year == Calendar.current.year && week == nil {
            // If it's the current year, setup the current week for this year
            setupCurrentSeasonWeek()
        } else {
            // Otherwise, default to the first week for this year
            if let firstWeek = self.weeks?.first {
                week = firstWeek
            } else {
                // TODO: Show "No events for current year"
            }
        }
        
        DispatchQueue.main.async {
            self.updateInterface()
        }
    }
    
    // MARK: - Observers
    
    func fetchedTBAStatus(notification: NSNotification) {
        // TODO: Make sure we don't handle this if we already have both of these set
        print("Fetched TBA status")
        guard let status = notification.object as? TBAStatus else {
            // TODO: Show error message
            return
        }
        self.year = Int(status.currentSeason)
        self.maxYear = Int(status.maxSeason)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue && (maxYear == nil || year == nil) {
            return false
        } else if identifier == SelectWeekSegue && (weeks == nil || week == nil) {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue || segue.identifier == SelectWeekSegue {
            let nav = segue.destination as! UINavigationController
            let selectYearTableViewController = nav.viewControllers.first as! SelectNumberTableViewController
            
            if segue.identifier == SelectYearSegue {
                selectYearTableViewController.selectNumberType = .year
                selectYearTableViewController.currentNumber = year
                selectYearTableViewController.numbers = Array(1992...maxYear!).reversed()
                selectYearTableViewController.numberSelected = { number in
                    self.year = number
                }
            } else {
                /*
                selectYearTableViewController.selectNumberType = .week
                selectYearTableViewController.currentNumber = weeks.first!.week
                selectYearTableViewController.numbers = Array(weeks!).reversed()
                selectYearTableViewController.numberSelected = { number in
                    self.week = number
                }
                */
            }
        } else if segue.identifier == EventSegue {
            let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
            eventViewController.event = sender as? Event
        } else if segue.identifier == EventsEmbed {
            eventsViewController = segue.destination as? EventsTableViewController
            if let weeks = weeks {
                eventsViewController!.week = weeks.first!.week
            } else {
                // TODO: Show loading that we're fetching weeks...
            }
            eventsViewController!.year = year
            
            eventsViewController!.eventsFetched = {
                self.setupWeeks()
            }
            eventsViewController!.eventSelected = { event in
                self.performSegue(withIdentifier: EventSegue, sender: event)
            }
        }
    }
    
}
