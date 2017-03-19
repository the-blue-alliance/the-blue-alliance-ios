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

let EventsEmbed = "EventsEmbed"
let EventSegue = "EventSegue"
let SelectYearSegue = "SelectYearSegue"

class EventsContainerViewController: TBAViewController {
    
    internal var eventsViewController: EventsTableViewController?
    @IBOutlet internal var eventsView: UIView?
    
    internal var weeks: [Int]?
    internal var week: Int = 1
    internal var year: Int {
        didSet {
            eventsViewController?.year = year
            updateInterface()
        }
    }
    internal var maxYear = { () -> Int in
        var maxYear = UserDefaults.standard.integer(forKey: StatusConstants.maxSeasonKey)
        if maxYear == 0 {
            // Default to the last safe year we know about
            maxYear = 2017
        }
        return maxYear
    }

    required init?(coder aDecoder: NSCoder) {
        let year = UserDefaults.standard.integer(forKey: StatusConstants.currentSeasonKey)
        self.year = year != 0 ? year : 2017

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [eventsViewController!]
        containerViews = [eventsView!]
        
        updateInterface()
    }
    
    // MARK: - Private Methods

    func updateInterface() {
        if week == -1 {
            navigationTitleLabel?.text = "---- Events"
        } else {
            navigationTitleLabel?.text = "Week \(week) Events"
        }
        
        navigationDetailLabel?.text = "▾ \(year)"
    }
    
    func setupCurrentWeek() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "year == %ld", year)
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        // TODO: Do we sort by week or startDate... or endDate?
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true)]
        fetchRequest.propertiesToFetch = ["startDate", "endDate", "week"].map({ (propertyName) -> NSPropertyDescription in
            return Event.entity().propertiesByName[propertyName]!
        })
        
        guard let eventDates = try? persistentContainer?.viewContext.fetch(fetchRequest) as! [[String: Any]] else {
            // TODO: Throw init error
            return
        }
        
        if eventDates.count == 0 {
            // TODO: This is no good... we need to have some events. Show a "No Events for this year" data state?
        }
        
        /*
         let currentDate = Date()
         var newestEvent = eventDates.first
         for eventDate in eventDates.dropFirst() {
         if currentDate >
         
         let newestEndDate = newestEvent["endDate"]
         let startDate = eventDate["startDate"]
         // let endDate = eventDate["endDate"]
         }
         */
    }
    
    func setupWeeks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "year == %ld", year)
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.propertiesToFetch = [Event.entity().propertiesByName["week"]!]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true)]
        fetchRequest.returnsDistinctResults = true
        
        guard let weeks = try? persistentContainer?.viewContext.fetch(fetchRequest) as! [[String: NSNumber]] else {
            // TODO: Throw init error
            return
        }
        
        self.weeks = weeks.map({ (_ weekDict: [String: NSNumber]) -> Int in
            // TODO: Don't force upwrap zachzor
            return weekDict["week"]!.intValue
        })
        
        if year == Calendar.current.year && week == -1 {
            // If it's the current year, setup the current week for this year
            setupCurrentWeek()
        } else {
            // Otherwise, default to the first week for this year
            if let firstWeek = self.weeks?.first {
                week = firstWeek
            } else {
                // TODO: Show "No events for current year"
            }
        }
        updateInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue {
            let nav = segue.destination as! UINavigationController
            let selectYearTableViewController = nav.viewControllers.first as! SelectNumberTableViewController
            selectYearTableViewController.selectNumberType = .year
            selectYearTableViewController.currentNumber = year
            selectYearTableViewController.numbers = Array(1992...maxYear()).reversed()
            selectYearTableViewController.numberSelected = { number in
                self.year = number
            }
        } else if segue.identifier == EventSegue {
            let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
            eventViewController.event = sender as? Event
        } else if segue.identifier == EventsEmbed {
            eventsViewController = segue.destination as? EventsTableViewController
            if let weeks = weeks {
                eventsViewController!.week = weeks.first!
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
