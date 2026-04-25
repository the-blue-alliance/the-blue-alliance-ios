import MyTBAKit
import Photos
import TBAAPI
import UIKit

enum MatchState {
    case key(String)
    case match(Match)

    var key: String {
        switch self {
        case .key(let key): return key
        case .match(let match): return match.key
        }
    }

    var match: Match? {
        switch self {
        case .key: return nil
        case .match(let match): return match
        }
    }
}

class MatchViewController: MyTBAContainerViewController {

    private var state: MatchState
    private let teamKey: String?

    private(set) var infoViewController: MatchInfoViewController
    private let breakdownViewController: MatchBreakdownViewController

    override var subscribableModel: MyTBASubscribable {
        MatchSubscribable(modelKey: state.key)
    }

    // MARK: Init

    convenience init(matchKey: String, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(state: .key(matchKey), teamKey: teamKey, dependencies: dependencies)
    }

    convenience init(match: Match, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(state: .match(match), teamKey: teamKey, dependencies: dependencies)
    }

    private init(state: MatchState, teamKey: String?, dependencies: Dependencies) {
        self.state = state
        self.teamKey = teamKey

        switch state {
        case .key(let matchKey):
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
        case .match(let match):
            infoViewController = MatchInfoViewController(
                match: match,
                teamKey: teamKey,
                dependencies: dependencies
            )
            breakdownViewController = MatchBreakdownViewController(
                match: match,
                dependencies: dependencies
            )
        }

        let navTitle = state.match?.friendlyName ?? state.key
        super.init(
            viewControllers: [infoViewController, breakdownViewController],
            navigationTitle: navTitle,
            navigationSubtitle: nil,
            segmentedControlTitles: ["Info", "Breakdown"],
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

        dependencies.reporter.log("Match: \(state.key)")
    }

    private func loadMatchAndEvent() {
        Task { @MainActor in
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let matchHandle = Task { try? await self.dependencies.api.match(key: self.state.key) }
            let eventHandle = Task {
                try? await self.dependencies.api.event(key: MatchKey.eventKey(from: self.state.key))
            }

            if let match = await matchHandle.value {
                self.state = .match(match)
                self.navigationTitle = match.friendlyName
            }
            if let event = await eventHandle.value {
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

    func teamPressed(teamKey: TeamKey) {
        guard let match = state.match, match.allTeamKeys.contains(teamKey) else { return }
        let year = match.year ?? 0
        let teamAtEventVC = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: match.eventKey,
            year: year,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamAtEventVC, animated: true)
    }

}
