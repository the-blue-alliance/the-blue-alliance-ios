import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class TeamAtEventViewController: ContainerViewController {

    let teamKey: String
    let eventKey: String

    var matchesViewController: MatchesViewController

    private let summaryViewController: TeamSummaryViewController
    private let statsViewController: TeamStatsViewController
    private let awardsViewController: EventAwardsViewController
    private let mediaViewController: TeamMediaCollectionViewController

    // MARK: - Init

    init(teamKey: TeamKey, eventKey: String, year: Int, dependencies: Dependencies) {
        // B teams (e.g. "frc5940B") alias their parent team — there's no
        // /team/<N>B page, so route every caller to the canonical key.
        let teamKey = teamKey.parentKey
        self.teamKey = teamKey
        self.eventKey = eventKey

        summaryViewController = TeamSummaryViewController(
            teamKey: teamKey,
            eventKey: eventKey,
            dependencies: dependencies
        )
        matchesViewController = MatchesViewController(
            eventKey: eventKey,
            teamKey: teamKey,
            dependencies: dependencies
        )
        mediaViewController = TeamMediaCollectionViewController(
            teamKey: teamKey,
            year: year,
            dependencies: dependencies
        )
        statsViewController = TeamStatsViewController(
            teamKey: teamKey,
            eventKey: eventKey,
            dependencies: dependencies
        )
        awardsViewController = EventAwardsViewController(
            eventKey: eventKey,
            teamKey: teamKey,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [
                summaryViewController, matchesViewController, mediaViewController,
                statsViewController,
                awardsViewController,
            ],
            navigationTitle: "Team \(teamKey.trimPrefix)",
            navigationSubtitle: nil,
            segmentedControlTitles: ["Summary", "Matches", "Media", "Stats", "Awards"],
            dependencies: dependencies
        )

        rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage.eventIcon,
                style: .plain,
                target: self,
                action: #selector(pushEvent)
            )
        ]

        summaryViewController.delegate = self
        matchesViewController.delegate = self
        mediaViewController.delegate = self
        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        Task { @MainActor in
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let eventHandle = Task { try? await self.dependencies.api.event(key: self.eventKey) }
            let teamHandle = Task { try? await self.dependencies.api.team(key: self.teamKey) }

            let team = await teamHandle.value
            let event = await eventHandle.value

            if let team {
                self.navigationTitle = team.teamNumberNickname
            }
            if let event {
                self.navigationSubtitle = "@ \(event.friendlyNameWithYear)"
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Team@Event: Event \(eventKey) | Team \(teamKey)")
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(
            eventKey: eventKey,
            dependencies: dependencies
        )
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    private func pushTeamAtEvent(teamKey: String, eventKey: String, year: Int) {
        let vc = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: eventKey,
            year: year,
            dependencies: dependencies
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushTeam(teamKey: String) {
        let vc = TeamViewController(teamKey: teamKey, dependencies: dependencies)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushMatch(_ match: Match) {
        let matchViewController = MatchViewController(
            match: match,
            teamKey: teamKey,
            dependencies: dependencies
        )
        navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable,
    TeamSummaryViewControllerDelegate
{

    func teamInfoSelected(teamKey: String) {
        pushTeam(teamKey: teamKey)
    }

    func matchSelected(_ match: Match) {
        pushMatch(match)
    }

}

extension TeamAtEventViewController: MediaViewer, TeamMediaCollectionViewControllerDelegate {

    func mediaSelected(image: UIImage?, directURL: URL?) {
        show(image: image, directURL: directURL)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamSelected(teamKey: String) {
        // Don't push to team@event for the team we're already showing team@event for
        if self.teamKey == teamKey {
            return
        }
        guard let year = Int(eventKey.prefix(4)) else { return }
        pushTeamAtEvent(teamKey: teamKey, eventKey: eventKey, year: year)
    }

}
