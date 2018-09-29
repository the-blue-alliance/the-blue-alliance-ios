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

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistrictEvents(key: district.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: self.district.objectID) as! District
                let localEvents = events?.map({ (modelEvent) -> Event in
                    return Event.insert(with: modelEvent, in: backgroundContext)
                })
                backgroundDistrict.events = Set(localEvents ?? []) as NSSet

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
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
