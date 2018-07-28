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
    // The selected Event from the weekEvents array to represent the Week to show
    // We need a full object as opposed to a number because of CMP, off-season, etc.
    internal var weekEvent: Event? {
        didSet {
            updateDataSource()
        }
    }
    internal var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }

    var eventSelected: ((Event) -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil), forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
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

    func refreshAllEvents() {
        guard let year = year else {
            return
        }

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEvents(year: year, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                events?.forEach({ (modelEvent) in
                    _ = Event.insert(with: modelEvent, in: backgroundContext)
                })

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    func refreshTeamEvents() {
        guard let team = team else {
            return
        }

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchTeamEvents(key: team.key!, completion: { (events, error) in
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
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    func refreshDistrictEvents() {
        guard let district = district else {
            return
        }

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistrictEvents(key: district.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: district.objectID) as! District
                let localEvents = events?.map({ (modelEvent) -> Event in
                    return Event.insert(with: modelEvent, in: backgroundContext)
                })
                backgroundDistrict.events = Set(localEvents ?? []) as NSSet

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: UITableView Delegate

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
        if let year = year, let weekEvent = weekEvent {
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
        } else if let year = year, let team = team {
            request.predicate = NSPredicate(format: "year == %ld AND ANY teams == %@", year, team)
        } else if let district = district {
            request.predicate = NSPredicate(format: "district == %@", district)
        } else {
            // Set this up so we fetch absolutely nothing and force a clear of all cells
            // Used to bust our table view/FRC after we change years in Events VC
            request.predicate = NSPredicate(format: "year == -1")
        }
    }

}

extension EventsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: EventTableViewCell, for object: Event, at indexPath: IndexPath) {
        cell.event = object
    }

    func title(for section: Int) -> String? {
        guard let event = dataSource?.object(at: IndexPath(item: 0, section: section)) else {
            return nil
        }
        
        if district != nil {
            return "\(event.weekString) Events"
        } else if event.isDistrictChampionship {
            guard let district = event.district, let eventTypeString = event.eventTypeString else {
                return nil
            }
            return Int(event.eventType) == EventType.districtChampionshipDivision.rawValue ? "\(district.name!) \(eventTypeString)s" : "\(eventTypeString)s"
        } else if event.isChampionship {
            guard let eventTypeString = event.eventTypeString else {
                return nil
            }
            // CMP Finals are already plural
            return Int(event.eventType) == EventType.championshipFinals.rawValue ? eventTypeString : "\(eventTypeString)s"
        } else if let district = event.district {
            return "\(district.name ?? "") District Events"
        } else if event.isFoC {
            return "Festival of Champions"
        } else if event.isOffseason {
            return "Offseason Events"
        } else if event.isPreseason {
            return "Preseason Events"
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
