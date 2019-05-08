import CoreData
import Foundation
import TBAKit

/**
 Although the weekEvent can be set via a YearSelect in the EventsContainerViewController, we need
 this delegate because on an initial load the weekEvent isn't set yet, and we have to set it and have
 the EventsContainerViewController respond to setting weekEvent in WeekEventsViewController.
 */
protocol WeekEventsDelegate: AnyObject {
    func weekEventUpdated()
}

class WeekEventsViewController: EventsViewController {

    private let year: Int
    weak var weekEventsDelegate: WeekEventsDelegate?

    // The selected Event from the weekEvents array to represent the Week to show
    // We need a full object as opposed to a number because of CMP, off-season, etc.
    var weekEvent: Event? {
        didSet {
            updateDataSource()
            DispatchQueue.main.async {
                // TODO: Scroll to top
            }
            weekEventsDelegate?.weekEventUpdated()
        }
    }
    var weeks: [Event] = []

    init(year: Int, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.year = year

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupWeeks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        return "\(year)_events"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 7)
    }

    override var automaticRefreshEndDate: Date? {
        // Automatically refresh the events for the duration of the year
        // Ex: 2019 events will stop automatically refreshing on Jan 1st, 2020
        return Calendar.current.date(from: DateComponents(year: year + 1))
    }

    @objc override func refresh() {
        removeNoDataView()

        // Default to refreshing the currently selected year
        // Fall back to the init'd year (used during initial refresh)
        var year = self.year
        if let weekEventYear = weekEvent?.year {
            year = weekEventYear.intValue
        }

        var request: URLSessionDataTask?
        request = tbaKit.fetchEvents(year: year, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let events = try? result.get() {
                    Event.insert(events, year: year, in: context)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
            self.setupWeeks()
        })
        addRequest(request: request!)
    }

    // MARK: - Stateful

    override var noDataText: String {
        return "No events for year"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate {
        if let weekEvent = weekEvent {
            if let week = weekEvent.week {
                // Event has a week - filter based on the week
                return NSPredicate(format: "%K == %@ && %K == %@",
                                   #keyPath(Event.week), week,
                                   #keyPath(Event.year), weekEvent.year!)
            } else {
                if weekEvent.eventType!.intValue == EventType.championshipFinals.rawValue {
                    // 2017 and onward - handle multiple CMPs
                    return NSPredicate(format: "(%K == %ld || %K == %ld) && %K == %@ && (%K == %@ || %K == %@)",
                                       #keyPath(Event.eventType), EventType.championshipFinals.rawValue,
                                       #keyPath(Event.eventType), EventType.championshipDivision.rawValue,
                                       #keyPath(Event.year), weekEvent.year!,
                                       #keyPath(Event.key), weekEvent.key!,
                                       #keyPath(Event.parentEvent.key), weekEvent.key!)
                } else if weekEvent.eventType!.intValue == EventType.offseason.rawValue {
                    // Get all off season events for selected month
                    // Conversion stuff, since Core Data still uses NSDate's
                    let firstDayOfMonth = NSDate(timeIntervalSince1970: weekEvent.startDate!.startOfMonth().timeIntervalSince1970)
                    let lastDayOfMonth = NSDate(timeIntervalSince1970: weekEvent.startDate!.endOfMonth().timeIntervalSince1970)
                    return NSPredicate(format: "%K == %ld && %K == %@ && (%K > %@) AND (%K <= %@)",
                                       #keyPath(Event.eventType), EventType.offseason.rawValue,
                                       #keyPath(Event.year), weekEvent.year!,
                                       #keyPath(Event.startDate), firstDayOfMonth,
                                       #keyPath(Event.endDate), lastDayOfMonth)
                } else {
                    return NSPredicate(format: "%K == %ld && %K == %@",
                                       #keyPath(Event.eventType), weekEvent.eventType!.intValue,
                                       #keyPath(Event.year), weekEvent.year!)
                }
            }
        }
        return NSPredicate(format: "%K == -1", #keyPath(Event.year))
    }

    // MARK: - Private

    private func setupWeeks() {
        // Only setup weeks if we don't have a currently selected week
        if weekEvent != nil {
            return
        }

        let weekEvents = Event.weekEvents(for: year, in: persistentContainer.viewContext)

        if year == Calendar.current.year {
            // If it's the current year, setup the current week for this year
            setupCurrentSeasonWeek()
        } else if let firstWeekEvent = weekEvents.first {
            // Otherwise, default to the first week for this years
            weekEvent = firstWeekEvent
        }
    }

    func setupCurrentSeasonWeek() {
        // Fetch all events where endDate is today or after today
        let coreDataDate = NSDate(timeIntervalSince1970: Date().startOfDay().timeIntervalSince1970)

        // Find the first non-finished event for the selected year
        let event = Event.fetchSingleObject(in: persistentContainer.viewContext) { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "%K == %ld && %K >= %@ && %K != %ld",
                                                 #keyPath(Event.year), year,
                                                 #keyPath(Event.endDate), coreDataDate,
                                                 #keyPath(Event.eventType), EventType.championshipDivision.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Event.endDate), ascending: true)]
        }
        // Find the first overall event for the selected year
        let firstEvent = Event.fetchSingleObject(in: persistentContainer.viewContext) { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "%K == %ld", #keyPath(Event.year), year)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Event.startDate), ascending: true)]
        }

        if let event = event {
            weekEvent = event
        } else if let firstEvent = firstEvent {
            weekEvent = firstEvent
        }
    }


}
