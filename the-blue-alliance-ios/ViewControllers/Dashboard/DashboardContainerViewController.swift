import Foundation
import MyTBAKit
import TBAAPI
import TBAUtils
import UIKit

class DashboardContainerViewController: ContainerViewController {

    private(set) var dashboardViewController: DashboardViewController

    // MARK: - Init

    init(dependencies: Dependencies) {
        dashboardViewController = DashboardViewController(dependencies: dependencies)

        super.init(
            viewControllers: [dashboardViewController],
            navigationTitle: RootType.dashboard.title,
            dependencies: dependencies
        )

        navigationItem.backButtonTitle = RootType.dashboard.title
        tabBarItem.image = RootType.dashboard.icon

        dashboardViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Dashboard")
    }

    // MARK: - Private Methods

    private static func subtitle(for phase: DashboardPhase) -> String {
        switch phase {
        case .offseason:
            return "Offseason"
        case .preKickoff(let season, _), .kickoff(let season, _):
            return "\(season) Kickoff"
        case .buildSeason(let season, _):
            return "\(season) Build Season"
        case .competition(let season, _, let weekLabel, _):
            return "\(weekLabel) · \(season)"
        case .championship(let season):
            return "\(season) Championship"
        }
    }

}

extension DashboardContainerViewController: DashboardViewControllerDelegate {

    func phaseUpdated(_ phase: DashboardPhase) {
        navigationSubtitle = Self.subtitle(for: phase)
    }

    func teamAtEventSelected(teamKey: String, eventKey: EventKey) {
        let teamAtEvent = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: eventKey,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamAtEvent, animated: true)
    }

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func matchSelected(_ match: Match, teamKey: String?) {
        let matchViewController = MatchViewController(
            match: match,
            teamKey: teamKey,
            dependencies: dependencies
        )
        navigationController?.pushViewController(matchViewController, animated: true)
    }

    // Sections that don't have a tab in this layout (myTBA sits behind More when the Dashboard is
    // on) are pushed instead.
    func tabSelected(_ type: RootType) {
        // The Search tab is a `UISearchTab`, which isn't created with our identifier.
        let tab =
            type == .search
            ? tabBarController?.tabs.first { $0 is UISearchTab }
            : tabBarController?.tab(forIdentifier: type.tabIdentifier)
        if let tab {
            tabBarController?.selectedTab = tab
            return
        }
        guard type == .myTBA else { return }
        navigationController?.pushViewController(
            MyTBAViewController(dependencies: dependencies),
            animated: true
        )
    }

}
