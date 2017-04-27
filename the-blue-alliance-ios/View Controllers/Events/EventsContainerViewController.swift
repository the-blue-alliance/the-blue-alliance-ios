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
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        // Preseason events should always come first
        if lhs.type == EventType.preseason.rawValue || rhs.type == EventType.preseason.rawValue {
            // Preseason, being 100, has the highest event type. So even though this seems backwards... it's not
            return lhs.type > rhs.type
        }
        // Unlabeled events go at the very end no matter what
        if lhs.type == EventType.unlabeled.rawValue || rhs.type == EventType.unlabeled.rawValue {
            // Same as preseason - unlabeled events are the lowest possible number so even though this line seems backwards it's not
            return lhs.type > rhs.type
        }
        // Offseason events come after everything besides unlabeled
        if lhs.type == EventType.offseason.rawValue || rhs.type == EventType.offseason.rawValue {
            // We've already handled preseason (100) so now we can assume offseason's (99) will always be the highest type
            return lhs.type < rhs.type
        }
        // CMP finals come after everything besides offseason, unlabeled
        if lhs.type == EventType.championshipFinals.rawValue || rhs.type == EventType.championshipFinals.rawValue {
            // Make sure we handle that districtCMPDivision case
            if lhs.type == EventType.districtChampionshipDivision.rawValue || rhs.type == EventType.districtChampionshipDivision.rawValue {
                return lhs.type > rhs.type
            } else {
                return lhs.type < rhs.type
            }
        }
        // CMP divisions are next
        if lhs.type == EventType.championshipDivision.rawValue || rhs.type == EventType.championshipDivision.rawValue {
            // Make sure we handle that districtCMPDivision case
            if lhs.type == EventType.districtChampionshipDivision.rawValue || rhs.type == EventType.districtChampionshipDivision.rawValue {
                return lhs.type > rhs.type
            } else {
                return lhs.type < rhs.type
            }
        }
        // EVERYTHING ELSE (districts, regionals, DCMPs, DCMP divisions) has weeks. This is just an easy sort... which event has a first week
        // Only weird thing is how we're sorting events that have the same weeks. It goes...
        // Regional < District < DCMP Division < DCMP
        if let lhsWeek = lhs.week, let rhsWeek = rhs.week {
            if lhsWeek == rhsWeek {
                // Make sure we handle the weird case of district championship divisions being a higher number than DCMPs
                if (lhs.type == EventType.districtChampionshipDivision.rawValue || rhs.type == EventType.districtChampionshipDivision.rawValue) &&
                    (lhs.type == EventType.districtChampionship.rawValue || rhs.type == EventType.districtChampionship.rawValue) {
                    return lhs.type > rhs.type
                } else {
                    return lhs.type < rhs.type
                }
            } else {
                return lhsWeek < rhsWeek
            }
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
        if type == EventType.championshipDivision.rawValue || type == EventType.championshipFinals.rawValue {
            // TODO: Need to handle different CMPs - "FIRST Championship - Houston" and "FIRST Championship - St. Louis"
            weekString = "Championship"
        } else {
            switch type {
            case EventType.unlabeled.rawValue:
                weekString = "Other"
            case EventType.preseason.rawValue:
                weekString = "Preseason"
            case EventType.offseason.rawValue:
                weekString = "Offseason"
            default:
                guard let week = week else {
                    return "Other"
                }

                /**
                 * Special cases for 2016:
                 * Week 1 is actually Week 0.5, eveything else is one less
                 * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
                 */
                if year == 2016 {
                    if week == 0 {
                        weekString = "Week 0.5"
                    } else {
                        weekString = "Week \(week)"
                    }
                } else {
                    weekString = "Week \(week + 1)"
                }
            }
        }
        return weekString
    }
    
}

class EventsContainerViewController: TBAViewController {
    internal var eventsViewController: EventsTableViewController?
    @IBOutlet internal var eventsView: UIView?
    @IBOutlet internal var weeksButton: UIBarButtonItem?
    
    internal var weeks: [EventOrder] = []
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
            navigationTitleLabel?.text = "\(week.description) Events"
        } else {
            navigationTitleLabel?.text = "---- Events"
        }
        
        if let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
        
        if !weeks.isEmpty {
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
        
        var handledWeeks: Set<Int> = []
        var handledTypes: Set<Int> = []
        self.weeks = Array(events.flatMap({ (e) -> EventOrder? in
            if let week = e.week {
                // Make sure each week only shows up once
                if handledWeeks.contains(week.intValue) {
                    return nil
                }
                handledWeeks.insert(week.intValue)
                return EventOrder(type: Int(e.eventType), week: week.intValue, year: year)
            } else if Int(e.eventType) == EventType.championshipDivision.rawValue {
                // Drop all district CMP divisions (they're grouped under CMPs not weeks)
                return nil
            } else if Int(e.eventType) == EventType.championshipFinals.rawValue {
                // Always add all CMP finals
                return EventOrder(type: Int(e.eventType), week: nil, year: year)
            } else {
                // Make sure we only have preseason, offseason, unlabeled once
                if handledTypes.contains(Int(e.eventType)) {
                    return nil
                }
                handledTypes.insert(Int(e.eventType))
                return EventOrder(type: Int(e.eventType), week: nil, year: year)
            }
        })).sorted()
        
        if year == Calendar.current.year && week == nil {
            // If it's the current year, setup the current week for this year
            setupCurrentSeasonWeek()
        } else {
            // Otherwise, default to the first week for this year
            if let firstWeek = self.weeks.first {
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
        } else if identifier == SelectWeekSegue && (weeks.isEmpty || week == nil) {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue || segue.identifier == SelectWeekSegue {
            let nav = segue.destination as! UINavigationController
            
            if segue.identifier == SelectYearSegue {
                let selectTableViewController = SelectTableViewController<Int>()
                selectTableViewController.current = year
                selectTableViewController.options = Array(1992...maxYear!).reversed()
                selectTableViewController.optionSelected = { year in
                    self.year = year
                }
                selectTableViewController.optionString = { year in
                    return String(year)
                }
                nav.viewControllers = [selectTableViewController]
            } else {
                let selectTableViewController = SelectTableViewController<EventOrder>()
                selectTableViewController.current = week!
                selectTableViewController.options = weeks
                selectTableViewController.optionSelected = { week in
                    self.week = week
                }
                selectTableViewController.optionString = { week in
                    return week.description
                }
                nav.viewControllers = [selectTableViewController]
            }
        } else if segue.identifier == EventSegue {
            let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
            eventViewController.event = sender as? Event
        } else if segue.identifier == EventsEmbed {
            eventsViewController = segue.destination as? EventsTableViewController
            if !weeks.isEmpty {
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
