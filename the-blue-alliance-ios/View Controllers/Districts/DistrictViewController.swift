import CoreData
import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    private let district: District
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    private var eventsViewController: DistrictEventsViewController!
    private var rankingsViewController: DistrictRankingsViewController!

    override var viewControllers: [ContainableViewController] {
        return [eventsViewController, rankingsViewController]
    }

    // MARK: - Init

    init(district: District, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.district = district
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        super.init(segmentedControlTitles: ["Events", "Rankings"],
                   persistentContainer: persistentContainer)

        eventsViewController = DistrictEventsViewController(district: district, persistentContainer: persistentContainer)
        eventsViewController.delegate = self

        rankingsViewController = DistrictRankingsViewController(district: district, delegate: self, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(district.year) \(district.name!) Districts"

        // TODO: Why do we do this? Has to do with the split view I know
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }

}

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
