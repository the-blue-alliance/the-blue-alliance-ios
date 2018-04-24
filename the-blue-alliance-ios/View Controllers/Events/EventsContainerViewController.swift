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

class EventsContainerViewController: ContainerViewController {
    internal var eventsViewController: EventsTableViewController!
    @IBOutlet internal var eventsView: UIView!
    @IBOutlet internal var weeksButton: UIBarButtonItem?
    
    internal var hasRefreshed: Bool = false
    internal var weeks: [Event]?
    internal var maxYear: Int?
    internal var week: Event? {
        didSet {
            if let eventsViewController = eventsViewController {
                eventsViewController.weekEvent = week
            }

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    internal var year: Int? {
        didSet {
            eventsViewController.year = year
            
            // Year changed - remove our previously selected week
            week = nil
            weeks = nil
            hasRefreshed = false
            
            setupWeeks()
            
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let year = UserDefaults.standard.integer(forKey: StatusConstants.currentSeasonKey)
        if year != 0 {
            self.year = year
        }
        
        let maxYear = UserDefaults.standard.integer(forKey: StatusConstants.maxSeasonKey)
        if maxYear != 0 {
            self.maxYear = maxYear
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchedTBAStatus),
                                               name: Notification.Name(kFetchedTBAStatus),
                                               object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [eventsViewController]
        containerViews = [eventsView]
        
        if year != nil {
            setupWeeks()
        }

        updateInterface()
    }
    
    // MARK: - Private Methods

    func updateInterface() {
        if let week = week {
            navigationTitleLabel?.text = "\(week.weekString) Events"
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
            weeksButton?.isEnabled = true
        } else {
            weeksButton?.title = "----"
            weeksButton?.isEnabled = false
        }
        
        if year == nil, week == nil {
            // Show loading
        } else {
            // Hide loading
        }
    }
    
    func setupCurrentSeasonWeek() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            return
        }

        // Fetch all events where endDate is today or after today
        let date = Date()
        
        // Remove time from date - we only care about the day
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        
        // Conversion stuff because Core Data still uses NSDates
        guard let swiftDate = Calendar.current.date(from: components) else {
            showErrorAlert(with: "Unable to setup current season week - datetime conversion failed")
            return
        }
        let coreDataDate = NSDate(timeIntervalSince1970: swiftDate.timeIntervalSince1970)
        
        let event = Event.fetchSingleObject(in: persistentContainer.viewContext) { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "year == %ld && endDate >= %@ && eventType != %ld", year, coreDataDate, EventType.championshipDivision.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        }
        let firstEvent = Event.fetchSingleObject(in: persistentContainer.viewContext) { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "year == %ld", year)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        }
        
        if let event = event {
            self.week = event
        } else if let firstEvent = firstEvent {
            // Couldn't get events for the year... use the *first* event for this year
            self.week = firstEvent
        } else {
            showErrorAlert(with: "Unable to setup current season week - no events for year")
        }
    }
    
    func setupWeeks() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            return
        }
        
        let events = Event.fetch(in: persistentContainer.viewContext) { (fetchRequest) in
            // Filter out CMP divisions
            fetchRequest.predicate = NSPredicate(format: "year == %ld && eventType != %ld", year, EventType.championshipDivision.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true), NSSortDescriptor(key: "eventType", ascending: true), NSSortDescriptor(key: "endDate", ascending: true)]
        }
        
        if events.isEmpty && !hasRefreshed {
            // Initial load of events for eventsVC
            if eventsViewController.shouldRefresh() {
                hasRefreshed = true
                eventsViewController.refresh()
            }
            return
        } else if hasRefreshed {
            showNoDataView(with: "No events for year")
            return
        }

        // Jesus, take the wheel
        var handledWeeks: Set<Int> = []
        var handledTypes: Set<Int> = []
        self.weeks = Array(events.compactMap({ (event) -> Event? in
            let eventType = Int(event.eventType)
            if let week = event.week {
                // Make sure each week only shows up once
                if handledWeeks.contains(week.intValue) {
                    return nil
                }
                handledWeeks.insert(week.intValue)
                return event
            } else if eventType == EventType.championshipFinals.rawValue {
                // Always add all CMP finals
                return event
            } else {
                // Make sure we only have preseason, offseason, unlabeled once
                if handledTypes.contains(eventType) {
                    return nil
                }
                handledTypes.insert(eventType)
                return event
            }
        })).sorted()
        
        if year == Calendar.current.year, week == nil {
            // If it's the current year, setup the current week for this year
            setupCurrentSeasonWeek()
        } else {
            // Otherwise, default to the first week for this year
            if let firstWeek = weeks?.first {
                week = firstWeek
            } else {
                showErrorAlert(with: "Unable to setup weeks - no events for selected year")
            }
        }
        
        DispatchQueue.main.async {
            self.updateInterface()
        }
    }
    
    // MARK: - Observers
    
    @objc func fetchedTBAStatus(notification: NSNotification) {
        guard let status = notification.object as? TBAStatus else {
            showErrorAlert(with: "TBA status fetch failed")
            return
        }
        if year == nil {
            year = Int(status.currentSeason)
        }
        maxYear = Int(status.maxSeason)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue, (maxYear == nil || year == nil) {
            return false
        } else if identifier == SelectWeekSegue, (weeks == nil || week == nil) {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue || segue.identifier == SelectWeekSegue {
            let nav = segue.destination as! UINavigationController
            
            if segue.identifier == SelectYearSegue {
                let selectTableViewController = SelectTableViewController<Int>()
                selectTableViewController.title = "Select Year"
                selectTableViewController.current = year
                selectTableViewController.options = Array(1992...maxYear!).reversed()
                selectTableViewController.optionSelected = { [weak self] year in
                    self?.year = year
                }
                selectTableViewController.optionString = { year in
                    return String(year)
                }
                nav.viewControllers = [selectTableViewController]
            } else {
                let selectTableViewController = SelectTableViewController<Event>()
                selectTableViewController.title = "Select Week"
                selectTableViewController.current = week!
                // Use compareCurrent for current season situation where the event stored in weeks may not actually
                // be equal to the event we have stored in week... because the current event might not be the first event
                selectTableViewController.compareCurrent = { current, option in
                    guard let current = current else {
                        return false
                    }
                    // Handle CMPs different - since CMP has the same type and the same week, check based on keys
                    let currentEventType = Int(current.eventType)
                    let optionEventType = Int(option.eventType)
                    if currentEventType == EventType.championshipFinals.rawValue, optionEventType == EventType.championshipFinals.rawValue {
                        return current.key! == option.key!
                    }
                    return (current.week == option.week) && (current.eventType == option.eventType)
                }
                selectTableViewController.options = weeks
                selectTableViewController.optionSelected = { [weak self] week in
                    self?.week = week
                }
                selectTableViewController.optionString = { week in
                    return week.weekString
                }
                nav.viewControllers = [selectTableViewController]
            }
        } else if segue.identifier == EventSegue {
            let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
            eventViewController.event = sender as? Event
            // TODO: Find a way to pass these down automagically like we did in the Obj-C version
            eventViewController.persistentContainer = persistentContainer
        } else if segue.identifier == EventsEmbed {
            eventsViewController = segue.destination as? EventsTableViewController
            eventsViewController.weekEvent = weeks?.first
            eventsViewController.year = year
            eventsViewController.eventsFetched = { [weak self] in
                self?.setupWeeks()
            }
            eventsViewController.eventSelected = { [weak self] event in
                self?.performSegue(withIdentifier: EventSegue, sender: event)
            }
        }
    }
    
}
