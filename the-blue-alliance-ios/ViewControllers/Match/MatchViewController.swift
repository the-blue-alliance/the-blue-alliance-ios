import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAAPI
import TBAData
import TBAKit
import UIKit

class MatchViewController: MyTBAContainerViewController {

    private let matchKey: String
    private let teamKey: String?

    private var match: Components.Schemas.Match?

    private(set) var infoViewController: MatchInfoViewController
    private let breakdownViewController: MatchBreakdownViewController

    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    override var subscribableModel: MyTBASubscribable {
        MatchSubscribable(modelKey: matchKey)
    }

    // MARK: Init

    init(matchKey: String, teamKey: String? = nil, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, myTBAStores: MyTBAStores, dependencies: Dependencies) {
        self.matchKey = matchKey
        self.teamKey = teamKey
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        infoViewController = MatchInfoViewController(matchKey: matchKey, teamKey: teamKey, dependencies: dependencies)
        breakdownViewController = MatchBreakdownViewController(matchKey: matchKey,
                                                               year: MatchKey.year(from: matchKey) ?? 0,
                                                               dependencies: dependencies)

        super.init(
            viewControllers: [infoViewController, breakdownViewController],
            navigationTitle: "Match",
            navigationSubtitle: nil,
            segmentedControlTitles: ["Info", "Breakdown"],
            myTBA: myTBA,
            myTBAStores: myTBAStores,
            dependencies: dependencies
        )

        infoViewController.matchSummaryDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadMatchAndEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Match: %@", [matchKey])
    }

    private func loadMatchAndEvent() {
        Task { @MainActor in
            async let matchTask = try? await dependencies.api.match(key: matchKey)
            async let eventTask = try? await dependencies.api.event(key: MatchKey.eventKey(from: matchKey))
            let (match, event) = await (matchTask, eventTask)

            if let match = match ?? nil {
                self.match = match
                self.navigationTitle = match.friendlyName
                self.infoViewController.apply(match: match)
                self.breakdownViewController.apply(match: match)
            }
            if let event = event ?? nil {
                self.navigationSubtitle = "@ \(event.friendlyNameWithYear)"
            }
        }
    }

}

private struct MatchSubscribable: MyTBASubscribable {
    let modelKey: String
    var modelType: MyTBAModelType { .match }
    static var notificationTypes: [NotificationType] {
        [.upcomingMatch, .matchScore, .matchVideo]
    }
}

extension MatchViewController: MatchSummaryViewDelegate {

    func teamPressed(teamNumber: Int) {
        let targetKey = "frc\(teamNumber)"
        guard let match, match.allTeamKeys.contains(targetKey) else { return }
        let year = match.year ?? 0
        let teamAtEventVC = TeamAtEventViewController(teamKey: targetKey, eventKey: match.eventKey, year: year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        navigationController?.pushViewController(teamAtEventVC, animated: true)
    }

}
