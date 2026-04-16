import MyTBAKit
import Photos
import TBAAPI
import UIKit

class DistrictViewController: ContainerViewController {

    private(set) var district: Components.Schemas.District
    private let year: Int
    private let myTBA: MyTBA
    private let myTBAStores: MyTBAStores
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var eventsViewController: DistrictEventsViewController
    private(set) var teamsViewController: DistrictTeamsViewController
    private(set) var rankingsViewController: DistrictRankingsViewController

    // MARK: - Init

    init(district: Components.Schemas.District, year: Int? = nil, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.district = district
        // District keys look like `2023fim` — year is the first 4 chars.
        let parsedYear = year ?? Int(district.key.prefix(4)) ?? statusService.currentSeason
        self.year = parsedYear
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        eventsViewController = DistrictEventsViewController(districtKey: district.key, year: parsedYear, dependencies: dependencies)
        teamsViewController = DistrictTeamsViewController(districtKey: district.key, year: parsedYear, dependencies: dependencies)
        rankingsViewController = DistrictRankingsViewController(districtKey: district.key, dependencies: dependencies)

        super.init(viewControllers: [eventsViewController, teamsViewController, rankingsViewController],
                   segmentedControlTitles: ["Events", "Teams", "Rankings"],
                   dependencies: dependencies)

        title = "\(parsedYear) \(district.displayName) Districts"

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

extension DistrictViewController: EventsListViewControllerDelegate {

    func eventSelected(_ event: Components.Schemas.Event) {
        let eventViewController = EventViewController(eventKey: event.key, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Components.Schemas.Event) -> String? {
        "\(event.weekString) Events"
    }

}

extension DistrictViewController: TeamsListViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamViewController = TeamViewController(teamKey: teamKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ ranking: Components.Schemas.DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: ranking, district: district, year: year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
