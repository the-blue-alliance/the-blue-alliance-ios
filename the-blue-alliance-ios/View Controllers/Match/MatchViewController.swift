import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class MatchViewController: MyTBAContainerViewController {

    private(set) var match: Match
    private lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    private(set) var infoViewController: MatchInfoViewController

    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    override var subscribableModel: MyTBASubscribable {
        return match
    }

    // MARK: Init

    init(match: Match, team: Team? = nil, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.match = match
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener
        infoViewController = MatchInfoViewController(match: match, team: team, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        // Only show match breakdown if year is 2015 or onward
        var titles: [String]  = ["Info"]
        let breakdownViewController: ContainableViewController? = {
            if match.event.year < 2015 {
                return nil
            }
            return MatchBreakdownViewController(match: match, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        }()
        if let _ = breakdownViewController {
            titles.append("Breakdown")
        }

        super.init(
            viewControllers: [infoViewController, breakdownViewController].compactMap({ $0 }),
            navigationTitle: "\(match.friendlyName)",
            navigationSubtitle: "@ \(match.event.friendlyNameWithYear)",
            segmentedControlTitles: titles,
            myTBA: myTBA,
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )

        infoViewController.matchSummaryDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contextObserver.observeObject(object: match.event, state: .updated) { [weak self] (event, _) in
            guard let self = self else { return }
            self.navigationSubtitle = "@ \(event.friendlyNameWithYear)"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("match", parameters: ["match": match.key])
    }

}

extension MatchViewController: MatchSummaryViewDelegate {
    
    func teamPressed(teamNumber: Int) {
        // get team key that matches the target teamNumber
        guard let team = match.teams.first(where: { Int($0.teamNumber) == teamNumber }) else { return }

        let teamAtEventVC = TeamAtEventViewController(team: team, event: match.event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(teamAtEventVC, animated: true)
    }
    
}
