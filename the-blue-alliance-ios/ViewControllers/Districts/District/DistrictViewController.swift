import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class DistrictViewController: ContainerViewController {

    private(set) var district: District
    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var eventsViewController: DistrictEventsViewController
    private(set) var teamsViewController: DistrictTeamsViewController
    private(set) var rankingsViewController: DistrictRankingsViewController

    // MARK: - Init

    init(district: District, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.district = district
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        eventsViewController = DistrictEventsViewController(district: district, dependencies: dependencies)
        teamsViewController = DistrictTeamsViewController(district: district, dependencies: dependencies)
        rankingsViewController = DistrictRankingsViewController(district: district, dependencies: dependencies)

        super.init(viewControllers: [eventsViewController, teamsViewController, rankingsViewController],
                   segmentedControlTitles: ["Events", "Teams", "Rankings"],
                   dependencies: dependencies)

        title = "\(district.year) \(district.name) Districts"

        eventsViewController.delegate = self
        teamsViewController.delegate = self
        rankingsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("District: %@", [district.key])
    }

}

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }

}

extension DistrictViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
