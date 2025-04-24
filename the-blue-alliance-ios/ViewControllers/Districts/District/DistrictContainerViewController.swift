import Firebase
import MyTBAKit
import Photos
import UIKit
import TBAAPI

class DistrictContainerViewController: SimpleContainerViewController {

    private let district: District

    private lazy var eventsViewController: DistrictEventsViewController = {
        let eventsViewController = DistrictEventsViewController(district: district, api: api)
        eventsViewController.delegate = self
        return eventsViewController
    }()
    // private(set) var teamsViewController: DistrictTeamsViewController
    private lazy var rankingsViewController: DistrictRankingsViewController = {
        let rankingsViewController = DistrictRankingsViewController(district: district, api: api)
        rankingsViewController.delegate = self
        return rankingsViewController
    }()

    // MARK: - Init

    init(district: District, api: TBAAPI) {
        self.district = district

        super.init(api: api)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = "\(district.year) \(district.name) Districts"

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

    // MARK: Container Data Source

    override var numberOfContainedViewControllers: Int {
        return 2
    }

    override func titleForSegment(at index: Int) -> String? {
        if index == 0 {
            return "Events"
        }
        return "Rankings"
    }

    override func viewControllerForSegment(at index: Int) -> UIViewController {
        if index == 0 {
            return eventsViewController
        }
        return rankingsViewController
    }

}

extension DistrictContainerViewController: SimpleEventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        /*
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(eventViewController, animated: true)
        */
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }
}

/*
extension DistrictViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}
*/

extension DistrictContainerViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        /*
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
        */
    }

}
