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
    
    var team: Team?
    var district: District?

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
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
        removeNoDataView()
        
        if team != nil {
            refreshTeamEvents()
        } else if district != nil {
            refreshDistrictEvents()
        } else {
            refreshAllEvents()
        }
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let events = dataSource?.fetchedResultsController.fetchedObjects, events.isEmpty {
            return true
        }
        return false
    }

    // TODO: Filter these refresh methods down to one method by doing something clever... it's the same code so
    func refreshAllEvents() {
        guard let year = year else {
            return
        }

        var request: URLSessionDataTask?
        request = TBAEvent.fetchEvents(year) { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                events?.forEach({ (modelEvent) in
                    _ = Event.insert(with: modelEvent, in: backgroundContext)
                })
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                } else if let eventsFetched = self.eventsFetched {
                    eventsFetched()
                }
                
                self.removeRequest(request: request!)
            })
        }
        addRequest(request: request!)
    }
    
    func refreshTeamEvents() {
        // Get all events for the team - we'll filter by year
        guard let team = team else {
            return
        }

        var request: URLSessionDataTask?
        request = TBATeam.fetchEventsForTeam(team.key!) { (events, error) in
            self.removeRequest(request: request!)
            
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: team.objectID) as! Team
                let localEvents = events?.map({ (modelEvent) -> Event in
                    return Event.insert(with: modelEvent, in: backgroundContext)
                })
                backgroundTeam.addToEvents(Set(localEvents ?? []) as NSSet)
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                } else if let eventsFetched = self.eventsFetched {
                    eventsFetched()
                }
                
                self.removeRequest(request: request!)
            })
        }
        addRequest(request: request!)
    }
    
    func refreshDistrictEvents() {
        guard let district = district else {
            return
        }
        
        var request: URLSessionDataTask?
        request = TBADistrict.fetchEvents(key: district.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: district.objectID) as! District
                let localEvents = events?.map({ (modelEvent) -> Event in
                    return Event.insert(with: modelEvent, in: backgroundContext)
                })
                backgroundDistrict.addToEvents(Set(localEvents ?? []) as NSSet)
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                } else if let eventsFetched = self.eventsFetched {
                    eventsFetched()
                }
                
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
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
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        var firstSortDescriptor = NSSortDescriptor(key: "hybridType", ascending: true)
        var sectionNameKeyPath = "hybridType"
        if district != nil {
            firstSortDescriptor = NSSortDescriptor(key: "week", ascending: true)
            sectionNameKeyPath = "week"
        }
        
        fetchRequest.sortDescriptors = [firstSortDescriptor,
                                        NSSortDescriptor(key: "startDate", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
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
        if let weekEvent = weekEvent, let year = year {
            if let week = weekEvent.week {
                // Event has a week - filter based on the week
                request.predicate = NSPredicate(format: "week == %ld && year == %ld", week.intValue, year)
            } else {
                if Int(weekEvent.eventType) == EventType.championshipFinals.rawValue {
                    // 2017 and onward - handle multiple CMPs
                    request.predicate = NSPredicate(format: "(eventType == %ld || eventType == %ld) && year == %ld && (key == %@ || parentEventKey == %@)", EventType.championshipFinals.rawValue, EventType.championshipDivision.rawValue, year, weekEvent.key!, weekEvent.key!)
                } else {
                    request.predicate = NSPredicate(format: "eventType == %ld && year == %ld", weekEvent.eventType, year)
                }
            }
        } else if let team = team, let year = year {
            request.predicate = NSPredicate(format: "year == %ld AND ANY teams == %@", year, team)
        } else if let district = district {
            request.predicate = NSPredicate(format: "district == %@", district)
        }
    }
    
}

extension EventsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: EventTableViewCell, for object: Event) {
        cell.event = object
    }
    
    func title(for section: Int) -> String? {
        guard let event = dataSource?.object(at: IndexPath(item: 0, section: section)) else {
            return nil
        }

        if let _ = district {
            return "\(event.weekString) Events"
        } else if let district = event.district {
            return "\(district.name ?? "") District Events"
        } else if event.isDistrictChampionship {
            guard let district = event.district, let eventTypeName = event.eventTypeName else {
                return nil
            }
            return Int(event.eventType) == EventType.districtChampionshipDivision.rawValue ? "\(district.name!) \(eventTypeName)s" : "\(eventTypeName)s"
        } else if event.isChampionship {
            guard let eventTypeName = event.eventTypeName else {
                return nil
            }
            // CMP Finals are already plural
            return Int(event.eventType) == EventType.championshipFinals.rawValue ? eventTypeName : "\(eventTypeName)s"
        } else {
            return "Regional Events"
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

