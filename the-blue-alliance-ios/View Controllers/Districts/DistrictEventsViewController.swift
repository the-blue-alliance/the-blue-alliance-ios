import CoreData
import Foundation
import TBAKit

class DistrictEventsViewController: EventsViewController {

    private let district: District

    init(district: District, persistentContainer: NSPersistentContainer) {
        self.district = district

        super.init(persistentContainer: persistentContainer)
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
        request = TBAKit.sharedKit.fetchDistrictEvents(key: district.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                if let events = events {
                    let district = backgroundContext.object(with: self.district.objectID) as! District
                    district.insert(events)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }

                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: - Stateful

    override var noDataText: String {
        return "No events for district"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var firstSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: "week", ascending: true)
    }

    override var sectionNameKeyPath: String {
        return "week"
    }

    override var fetchRequestPredicate: NSPredicate {
        return NSPredicate(format: "district == %@", district)
    }

}
