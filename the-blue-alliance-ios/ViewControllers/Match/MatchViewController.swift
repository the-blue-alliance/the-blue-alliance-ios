import MyTBAKit
import Photos
import TBAAPI
import UIKit

class MatchViewController: MyTBAContainerViewController {

    private let matchKey: String
    private let teamKey: String?

    private var match: Match?

    private(set) var infoViewController: MatchInfoViewController
    private let breakdownViewController: MatchBreakdownViewController

    override var subscribableModel: MyTBASubscribable {
        MatchSubscribable(modelKey: matchKey)
    }

    // MARK: Init

    init(matchKey: String, teamKey: String? = nil, dependencies: Dependencies) {
        self.matchKey = matchKey
        self.teamKey = teamKey

        infoViewController = MatchInfoViewController(
            matchKey: matchKey,
            teamKey: teamKey,
            dependencies: dependencies
        )
        breakdownViewController = MatchBreakdownViewController(
            matchKey: matchKey,
            year: MatchKey.year(from: matchKey) ?? 0,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [infoViewController, breakdownViewController],
            navigationTitle: "Match",
            navigationSubtitle: nil,
            segmentedControlTitles: ["Info", "Breakdown"],

            dependencies: dependencies
        )

        infoViewController.matchSummaryDelegate = self
    }

    convenience init(match: Match, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(matchKey: match.key, teamKey: teamKey, dependencies: dependencies)
        self.match = match
        self.navigationTitle = match.friendlyName
        self.infoViewController.apply(match: match)
        self.breakdownViewController.apply(match: match)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadMatchAndEvent()
    }

    private func loadMatchAndEvent() {
        Task { @MainActor in
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let matchHandle = Task { try? await self.dependencies.api.match(key: self.matchKey) }
            let eventHandle = Task {
                try? await self.dependencies.api.event(key: MatchKey.eventKey(from: self.matchKey))
            }

            let match = await matchHandle.value
            let event = await eventHandle.value

            if let match {
                self.match = match
                self.navigationTitle = match.friendlyName
                self.infoViewController.apply(match: match)
                self.breakdownViewController.apply(match: match)
            }
            if let event {
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
        let teamAtEventVC = TeamAtEventViewController(
            teamKey: targetKey,
            eventKey: match.eventKey,
            year: year,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamAtEventVC, animated: true)
    }

}
