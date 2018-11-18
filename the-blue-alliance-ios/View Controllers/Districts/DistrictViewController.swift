import CoreData
import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    private let district: District
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    // MARK: - Init

    init(district: District, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.district = district
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        let eventsViewController = DistrictEventsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let rankingsViewController = DistrictRankingsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit)

        super.init(viewControllers: [eventsViewController, rankingsViewController],
                   segmentedControlTitles: ["Events", "Rankings"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit)

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

        // TODO: Why do we do this? Has to do with the split view I know
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }

}

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
