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

class EventsTableViewController: TBATableViewController {
    
    internal var weekEvent: Event? {
        didSet {
            if dataSource == nil {
                setupTableView()
            } else {
                updateDataSource()
            }
        }
    }
    internal var year: Int? {
        didSet {
            if dataSource == nil {
                setupTableView()
            } else {
                updateDataSource()
            }
            
            if shouldNoDataRefresh() {
                refresh()
            }
        }
    }

    var eventsFetched: (() -> ())?
    var eventSelected: ((Event) -> ())?
    
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
        if let events = dataSource?.fetchedResultsController.fetchedObjects, events.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Can we move this somewhere else?
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed

        super.viewWillAppear(animated)
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor.primaryDarkBlue
            headerView.textLabel?.textColor = UIColor.white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    // MARK: Private
    
    fileprivate var dataSource: TableViewDataSource<Event, EventsTableViewController>?
    
    fileprivate func setupTableView() {
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: EventCellReuseIdentifier)
        
        tableView.delegate = self
        
        setupDataSource()
    }
    
    fileprivate func setupDataSource() {
        guard let _ = weekEvent else {
            // TODO: We need a week event
            return
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "district.name", ascending: true),
                                        NSSortDescriptor(key: "startDate", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "district.name", cacheName: nil)
        
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: EventCellReuseIdentifier, fetchedResultsController: frc, delegate: self)        
    }

    fileprivate func updateDataSource() {
        dataSource?.reconfigureFetchRequest(setupFetchRequest(_:))
    }
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Event>) {
        guard let weekEvent = weekEvent, let year = year else {
            return
        }

        if let week = weekEvent.week {
            // Event has a week - filter based on the week
            request.predicate = NSPredicate(format: "week == %ld && year == %ld", week.intValue, year)
        } else {
            if Int(weekEvent.eventType) == EventType.championshipFinals.rawValue {
                request.predicate = NSPredicate(format: "(eventType == %ld || eventType == %ld) && year == %ld", EventType.championshipFinals.rawValue, EventType.championshipDivision.rawValue, year)
            } else {
                request.predicate = NSPredicate(format: "eventType == %ld && year == %ld", weekEvent.eventType, year)
            }
        }
    }
    
}

extension EventsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: EventTableViewCell, for object: Event) {
        cell.event = object
    }
    
    func title(for section: Int) -> String? {
        let event = dataSource?.object(at: IndexPath(item: 0, section: section))
        if let district = event?.district {
            return "\(district.name!) Districts"
        } else {
            return "Regionals"
        }
    }
    
}
