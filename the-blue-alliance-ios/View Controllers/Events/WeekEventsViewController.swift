import CoreData
import Foundation
import TBAData
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

    init(year: Int, dependencies: Dependencies) {
        self.year = year
        self.weekEvent = WeekEventsViewController.weekEvent(for: year, in: dependencies.persistentContainer.viewContext)

        super.init(dependencies: dependencies)
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
        // Default to refreshing the currently selected year
        // Fall back to the init'd year (used during initial refresh)
        var year = self.year
        if let weekEventYear = weekEvent?.year {
            year = Int(weekEventYear)
        }

        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvents(year: year) { [unowned self] (result, notModified) in
            guard case .success(let events) = result, !notModified else {
                return
            }

            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Event.insert(events, year: year, in: context)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)

            // Only setup weeks if we don't have a currently selected week
            if self.weekEvent == nil {
                context.perform {
                    guard let we = WeekEventsViewController.weekEvent(for: year, in: context) else {
                        return
                    }
                    self.persistentContainer.viewContext.perform {
                        self.weekEvent = self.persistentContainer.viewContext.object(with: we.objectID) as? Event
                    }
                }
            }
        }
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No events for year"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate {
        if let weekEvent = weekEvent {
            guard let eventType = weekEvent.eventType else {
                return Event.unknownYearPredicate(year: weekEvent.year)
            }

            if let week = weekEvent.week {
                // Event has a week - filter based on the week
                return Event.weekYearPredicate(week: week, year: weekEvent.year)
            } else {
                if eventType == .championshipFinals {
                    return Event.champsYearPredicate(key: weekEvent.key, year: weekEvent.year)
                } else if eventType == .offseason {
                    // Get all off season events for selected month
                    return Event.offseasonYearPredicate(startDate: weekEvent.startDate!, endDate: weekEvent.endDate!, year: weekEvent.year)
                } else {
                    return Event.eventTypeYearPredicate(eventType: eventType, year: weekEvent.year)
                }
            }
        }
        return Event.nonePredicate()
    }

    // MARK: - Private

    private static func weekEvent(for year: Int, in context: NSManagedObjectContext) -> Event? {
        let weekEvents = Event.weekEvents(for: year, in: context)

        if year == Calendar.current.year {
            // If it's the current year, setup the current week for this year
            return currentSeasonWeekEvent(for: year, in: context)
        } else if let firstWeekEvent = weekEvents.first {
            // Otherwise, default to the first week for this years
            return firstWeekEvent
        }
        return nil
    }

    private static func currentSeasonWeekEvent(for year: Int, in context: NSManagedObjectContext) -> Event? {
        // Find the first non-finished event for the selected year
        let event = Event.fetchSingleObject(in: context) { (fetchRequest) in
            let predicate = Event.unplayedEventPredicate(date: Date().startOfDay(), year: year)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                Event.populatedEventsPredicate()
            ])
            fetchRequest.sortDescriptors = [
                Event.endDateSortDescriptor()
            ]
        }
        // Find the first overall event for the selected year
        let firstEvent = Event.fetchSingleObject(in: context) { (fetchRequest) in
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                Event.yearPredicate(year: year),
                Event.populatedEventsPredicate()
            ])
            fetchRequest.sortDescriptors = [
                Event.startDateSortDescriptor()
            ]
        }

        if let event = event {
            return event
        } else if let firstEvent = firstEvent {
            return firstEvent
        }
        return nil
    }


}
