//
//  EventsTableViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/7/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAKit
import CoreData

let EventCellReuseIdentifier = "EventCell"

class EventsTableViewController: UITableViewController, DynamicTableList {
    public var persistentContainer: NSPersistentContainer! {
        didSet {
            let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hybridType", ascending: true),
                                            NSSortDescriptor(key: "startDate", ascending: true),
                                            NSSortDescriptor(key: "name", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "week == %ld && year == %ld", week, year)
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer!.viewContext, sectionNameKeyPath: "hybridType", cacheName: nil)
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    typealias FetchedObject = Event
    public var fetchedResultsController: NSFetchedResultsController<Event>! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }

    @IBOutlet var navigationTitleLabel: UILabel?
    @IBOutlet var navigationDetailLabel: UILabel?
    
    internal var weeks: [Int]?
    internal var week: Int = 1
    internal var year = 2016
    /*
    internal var year: Int = {
        var year = UserDefaults.standard.integer(forKey: StatusConstants.currentSeasonKey)
        // TODO: We should really just wait until the currentSeasonKey is set... don't want to go over max season
        if year == 0 {
            year = Calendar.current.year
        }
        return year
    }()
    */

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TBAEvent.fetchEvents(year) { (events, error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error!", message: "Unable to load events", preferredStyle: .alert)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            print("Loaded \(events?.count) events")
            
            // TODO: The API for core data stuff is shit right now, take a pass at renaming
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                // Insert the events
                events?.forEach({ (modelEvent) in
                    do {
                        try Event.insert(with: modelEvent, in: backgroundContext)
                    } catch {
                        print("Unable to insert event: \(error)")
                    }
                })
                
                // Save the context.
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        self.setupWeeks()
                    }
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
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
    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount(at: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectItem(at: indexPath)
    }
    
    // MARK: - Data DynamicTableList
    
    public func cellIdentifier(at indexPath: IndexPath) -> String {
        return EventCellReuseIdentifier
    }
    
    func listView(_ listView: UITableView, configureCell cell: UITableViewCell, withObject object: Event, atIndexPath indexPath: IndexPath) {
        cell.textLabel?.text = object.name
    }
    
    public func listView(_ listView: UITableView, didSelectObject object: Event, atIndexPath indexPath: IndexPath) {
        // This doesn't need to have anything, set setup our segues in IB
    }
    
    // MARK: - Fetched Controller
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectYear" {
            let nav = segue.destination as! UINavigationController
            let selectYearTableViewController = nav.viewControllers.first as! SelectNumberTableViewController
            
            selectYearTableViewController.selectNumberType = .year
            selectYearTableViewController.currentNumber = year
            selectYearTableViewController.numbers = Array(1992...Calendar.current.year).reversed()
        } else if segue.identifier == "EventSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let event = fetchedResultsController.object(at: indexPath)
                let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
                eventViewController.event = event
                eventViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                eventViewController.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
}
