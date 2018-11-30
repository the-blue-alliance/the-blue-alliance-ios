import CoreData
import Foundation

class DistrictEventsViewController: EventsViewController {

    private let district: District

    init(district: District, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        return "\(district.key!)_events"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 7)
    }

    override var automaticRefreshEndDate: Date? {
        // Automatically refresh event districts during the year before the selected year (when events are rolling in)
        // Ex: Districts for 2019 will stop automatically refreshing on January 1st, 2019 (should all be set by then)
        return Calendar.current.date(from: DateComponents(year: district.year!.intValue))
    }

    @objc override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchDistrictEvents(key: district.key!, completion: { (events, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let events = events {
                    let district = context.object(with: self.district.objectID) as! District
                    district.insert(events)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

    // MARK: - Stateful

    override var noDataText: String {
        return "No events for district"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var firstSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.week), ascending: true)
    }

    override var sectionNameKeyPath: String {
        return #keyPath(Event.week)
    }

    override var fetchRequestPredicate: NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Event.district.key), district.key!)
    }

}
