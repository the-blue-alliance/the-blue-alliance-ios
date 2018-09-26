import Foundation
import UIKit
import CoreData
import TBAKit
import FirebaseRemoteConfig

class EventsContainerViewController: ContainerViewController, Observable {

    private let remoteConfig: RemoteConfig
    private let userDefaults: UserDefaults

    private var eventsViewController: EventsViewController!

    override var viewControllers: [ContainableViewController] {
        return [eventsViewController]
    }

    private lazy var weeksButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Weeks",
                               style: .plain,
                               target: self,
                               // action: #selector(showSelectWeek))
                               action: nil)
    }()

    // TODO: Is this still true.....?
    // Used to manually refresh the first time for a year change,
    // since our existing patterns won't refresh automatically
    private var hasRefreshed: Bool = false

    private var year: Int {
        didSet {
            // Update to make sure we're watching for events for the proper year
            updateEventObserver()

            // Year changed - remove our previously selected week
            weekEvent = nil
            weekEvents = []
            hasRefreshed = false

            // Pass down year change so it can update it's FRC predicate
            // Remove weekEvent before year on Events TVC - it's safer that way
            eventsViewController.year = year

            // Update available weeks for the year
            DispatchQueue.main.async {
                self.setupWeeks()
            }
        }
    }

    // An array of events that are used to represent their corresponding week in the Week selector
    // We need a full object as opposed to a number because of CMP, off-season, etc.
    // TODO: Convert this to a data model that uses a Core Data model for init but isn't a Core Data model
    private var weekEvents: [Event] = []
    // The selected Event from the weekEvents array to represent the Week to show
    private var weekEvent: Event? {
        didSet {
            // Pass down weekEvent change so it can update it's FRC predicate
            eventsViewController.weekEvent = weekEvent

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(remoteConfig: RemoteConfig, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.remoteConfig = remoteConfig
        self.userDefaults = userDefaults

        year = remoteConfig.currentSeason

        super.init(persistentContainer: persistentContainer)

        title = "Events"
        tabBarItem.image = UIImage(named: "ic_event")
        navigationItem.rightBarButtonItem = weeksButton
        navigationTitleDelegate = self

        eventsViewController = EventsViewController(year: year, delegate: self, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWeeks()
        updateInterface()
    }

    // MARK: - Private Methods

    private func updateInterface() {
        if let weekEvent = weekEvent {
            navigationTitle = "\(weekEvent.weekString) Events"
        } else {
            navigationTitle = "---- Events"
        }
        navigationSubtitle = "▾ \(year)"

        if weekEvents.isEmpty {
            weeksButton.title = "----"
            weeksButton.isEnabled = false
        } else {
            weeksButton.title = "Weeks"
            weeksButton.isEnabled = true
        }
    }

    func updateEventObserver() {
        // Ignore Championship divisions - we don't want to take them in to account during our weeks calculation,
        // so we don't bother watching for changes in them
        let predicate = NSPredicate(format: "year == %ld && eventType != %ld", year, EventType.championshipDivision.rawValue)
        contextObserver.observeInsertions(matchingPredicate: predicate) { [unowned self] (_) in
            DispatchQueue.main.async {
                self.setupWeeks()
            }
        }
    }

    func setupWeeks() {
        // If we fail to load our persistent container we don't want to crash here
        let events = Event.fetch(in: persistentContainer.viewContext) { (fetchRequest) in
            // Filter out CMP divisions - we don't want them below for our weeks calculation
            fetchRequest.predicate = NSPredicate(format: "year == %ld && eventType != %ld", year, EventType.championshipDivision.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true), NSSortDescriptor(key: "eventType", ascending: true), NSSortDescriptor(key: "endDate", ascending: true)]
        }

        if events.isEmpty && !hasRefreshed {
            // Initial load of events for eventsVC
            if eventsViewController.shouldRefresh() {
                hasRefreshed = true
                eventsViewController!.refresh()
            }
            return
        }

        // Take one event for each week(type) to use for our weekEvents array
        // ex: one Preseason, one Week 1, one Week 2..., one CMP #1, one CMP #2, one Offseason
        // Jesus, take the wheel
        var handledWeeks: Set<Int> = []
        var handledTypes: Set<Int> = []
        self.weekEvents = Array(events.compactMap({ (event) -> Event? in
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

        // If we don't have a weekEvent yet, set one
        // If we do have one, we don't want to jump where the user set their week to
        if weekEvent == nil {
            if year == Calendar.current.year {
                // If it's the current year, setup the current week for this year
                setupCurrentSeasonWeek()
            } else if let firstWeekEvent = weekEvents.first {
                // Otherwise, default to the first week for this years
                weekEvent = firstWeekEvent
            }
        }

        DispatchQueue.main.async {
            self.updateInterface()
        }
    }

    func setupCurrentSeasonWeek() {
        // Fetch all events where endDate is today or after today
        let date = Date()

        // Remove time from date - we only care about the day
        // We don't want to be too granular, or we bump forward too fast
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)

        // Conversion stuff because Core Data still uses NSDates
        guard let swiftDate = Calendar.current.date(from: components) else {
            showErrorAlert(with: "Unable to setup current season week - datetime conversion failed")
            return
        }
        let coreDataDate = NSDate(timeIntervalSince1970: swiftDate.timeIntervalSince1970)

        // Find the first non-finished event for the selected year
        let event = Event.fetchSingleObject(in: persistentContainer.viewContext) { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "year == %ld && endDate >= %@ && eventType != %ld", year, coreDataDate, EventType.championshipDivision.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        }
        // Find the first overall event for the selected year
        let firstEvent = Event.fetchSingleObject(in: persistentContainer.viewContext) { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "year == %ld", year)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        }

        if let event = event {
            weekEvent = event
        } else if let firstEvent = firstEvent {
            weekEvent = firstEvent
        }
    }

    /*
    func showSelectYear() {
        let selectTableViewController = SelectTableViewController<Int>()
        selectTableViewController.title = "Select Year"
        selectTableViewController.current = year
        selectTableViewController.options = Array(1992...remoteConfig.maxSeason).reversed()
        selectTableViewController.optionSelected = { [weak self] year in
            self?.year = year
        }
        selectTableViewController.optionString = { year in
            return String(year)
        }

        let navigationController = UINavigationController(rootViewController: selectTableViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }

    @objc func showSelectWeek() {
        if weekEvents.isEmpty || weekEvent == nil {
            return
        }

        let selectTableViewController = SelectTableViewController<Event>()
        selectTableViewController.title = "Select Week"
        selectTableViewController.current = weekEvent!
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
        selectTableViewController.options = weekEvents
        selectTableViewController.optionSelected = { [weak self] week in
            self?.weekEvent = week
        }
        selectTableViewController.optionString = { week in
            return week.weekString
        }

        let navigationController = UINavigationController(rootViewController: selectTableViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    */

}

extension EventsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        // showSelectYear()
    }

}

extension EventsContainerViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

}
