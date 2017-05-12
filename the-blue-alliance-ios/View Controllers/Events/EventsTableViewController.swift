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

class EventsTableViewController: TBATableViewController {
    
    internal var weekEvent: Event? {
        didSet {
            updateDataSource()
        }
    }
    internal var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
            
            if shouldNoDataRefresh() {
                refresh()
            }
        }
    }

    var eventsFetched: (() -> ())?
    var eventSelected: ((Event) -> ())?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil), forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    }
    
    // MARK: - Refreshing
        
    override func refresh() {
        guard let year = year else {
            return
        }
        
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAEvent.fetchEvents(year) { (events, error) in
            self.removeRequest(request: request!)

            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
                return
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                // Insert the events
                events?.forEach({ (modelEvent) in
                    do {
                        _ = try Event.insert(with: modelEvent, in: backgroundContext)
                    } catch let insertError {
                        self.showErrorAlert(with: "Unable to insert event - \(insertError.localizedDescription)")
                    }
                })
                
                try? backgroundContext.save()
                if let eventsFetched = self.eventsFetched {
                    eventsFetched()
                }
            })
        }
        addRequest(request: request!)
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let events = dataSource?.fetchedResultsController.fetchedObjects, events.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor.primaryDarkBlue
            headerView.textLabel?.textColor = UIColor.white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = dataSource?.object(at: indexPath)
        if let event = event, let eventSelected = eventSelected {
            eventSelected(event)
        }
    }
    
    // MARK: Table View Data Source
    
    fileprivate var dataSource: TableViewDataSource<Event, EventsTableViewController>?
    
    fileprivate func setupDataSource() {
        guard let _ = weekEvent else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "district.name", ascending: true),
                                        NSSortDescriptor(key: "startDate", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "district.name", cacheName: nil)
        
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: EventTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
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
    
    func showNoDataView() {
        // Only show no data if we've loaded data once
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load events")
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }
    
}
