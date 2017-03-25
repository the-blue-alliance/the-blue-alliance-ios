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

class EventsTableViewController: TBATableViewController, DynamicTableList {
    override public var persistentContainer: NSPersistentContainer? {
        didSet {
            guard let persistentContainer = persistentContainer, let year = year, let week = week else {
                return
            }
            
            let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "district.name", ascending: true),
                                            NSSortDescriptor(key: "startDate", ascending: true),
                                            NSSortDescriptor(key: "name", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "week == %ld && year == %ld", week, year)
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "district.name", cacheName: nil)
            
            do {
                try fetchedResultsController!.performFetch()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    typealias FetchedObject = Event
    public var fetchedResultsController: NSFetchedResultsController<Event>? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
    
    internal var week: Int? {
        didSet {
            clearFRC()
        }
    }
    internal var year: Int? {
        didSet {
            clearFRC()
            if shouldNoDataRefresh() {
                refresh()
            }
        }
    }
    var eventsFetched: (() -> ())?
    var eventSelected: ((Event) -> ())?

    func clearFRC() {
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: EventCellReuseIdentifier)
    }
    
    // MARK: - Refreshing
    
    func refresh() {
        guard let year = year else {
            return
        }
        
        var request: Int?
        request = TBAEvent.fetchEvents(year) { (events, error) in
            if error != nil {
                // self.showErrorAlert(withText: "Unable to load events - \(error!.localizedDescription)")
                return
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                // Insert the events
                events?.forEach({ (modelEvent) in
                    do {
                        _ = try Event.insert(with: modelEvent, in: backgroundContext)
                    } catch {
                        print("Unable to insert event: \(error)")
                    }
                })
                
                // Save the context.
                do {
                    try backgroundContext.save()
                    if let eventsFetched = self.eventsFetched {
                        eventsFetched()
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
    
    func shouldNoDataRefresh() -> Bool {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return false
        }
        return fetchedObjects.count == 0
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Can we move this somewhere else?
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed

        super.viewWillAppear(animated)
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor.primaryDarkBlue
            headerView.textLabel?.textColor = UIColor.white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let event = fetchedResultsController?.sections?[section].objects?.first as? Event, let district = event.district {
            return "\(district.name!) Districts"
        } else {
           return "Regionals"
        }
    }
    
    // MARK: - Data DynamicTableList
    
    public func cellIdentifier(at indexPath: IndexPath) -> String {
        return EventCellReuseIdentifier
    }
    
    func listView(_ listView: UITableView, configureCell cell: UITableViewCell, withObject object: Event, atIndexPath indexPath: IndexPath) {
        if let cell = cell as? EventTableViewCell {
            cell.event = object
        }
    }
    
    public func listView(_ listView: UITableView, didSelectObject object: Event, atIndexPath indexPath: IndexPath) {
        if let eventSelected = eventSelected {
            eventSelected(object)
        }
    }
    
    // MARK: - Fetched Controller
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}
