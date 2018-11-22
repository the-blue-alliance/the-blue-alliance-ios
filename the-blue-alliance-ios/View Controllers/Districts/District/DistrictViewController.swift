import CoreData
import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    private(set) var district: District
    private let urlOpener: URLOpener

    private(set) var eventsViewController: DistrictEventsViewController
    private(set) var rankingsViewController: DistrictRankingsViewController

    // MARK: - Init

    init(district: District, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district
        self.urlOpener = urlOpener

        eventsViewController = DistrictEventsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        rankingsViewController = DistrictRankingsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [eventsViewController, rankingsViewController],
                   segmentedControlTitles: ["Events", "Rankings"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        eventsViewController.delegate = self
        rankingsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(district.year!.stringValue) \(district.name!) Districts"

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

}

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
