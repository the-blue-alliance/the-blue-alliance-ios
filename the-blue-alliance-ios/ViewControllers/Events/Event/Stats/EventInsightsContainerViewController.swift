import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

class EventInsightsContainerViewController: ContainerViewController {

    private(set) var event: Event

    private let teamStatsViewController: EventTeamStatsTableViewController

    // MARK: - Init

    // Children go through locals: reading them off self before super.init
    // crashes the Swift 6.3.3 optimizer in Release builds.
    init(event: Event, dependencies: Dependencies) {
        self.event = event

        let teamStatsViewController = EventTeamStatsTableViewController(
            eventKey: event.key,
            dependencies: dependencies
        )
        self.teamStatsViewController = teamStatsViewController

        var viewControllers: [ContainableViewController] = [teamStatsViewController]
        var titles = ["Team Stats"]
        // Only show event insights if year is 2016 or onward
        if event.year >= 2016 {
            viewControllers.append(
                EventInsightsViewController(
                    eventKey: event.key,
                    year: event.year,
                    dependencies: dependencies
                )
            )
            titles.append("Event Insights")
        }

        super.init(
            viewControllers: viewControllers,
            navigationTitle: "Stats",
            navigationSubtitle: "@ \(event.friendlyNameWithYear)",
            segmentedControlTitles: titles,
            dependencies: dependencies
        )

        teamStatsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event Stats: \(event.key)")
    }

    // MARK: - Private Methods

    private func showFilter() {
        let selectTableViewController = SelectTableViewController<
            EventInsightsContainerViewController
        >(
            current: teamStatsViewController.filter,
            options: EventTeamStatFilter.allCases,
            dependencies: dependencies
        )
        selectTableViewController.title = "Sort stats by"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )

        navigationController?.present(nav, animated: true)
    }

}

extension EventInsightsContainerViewController: SelectTableViewControllerDelegate {

    typealias OptionType = EventTeamStatFilter

    func optionSelected(_ option: OptionType) {
        teamStatsViewController.filter = option
    }

    func titleForOption(_ option: OptionType) -> String {
        return option.rawValue
    }

}

extension EventInsightsContainerViewController: EventTeamStatsSelectionDelegate {

    func filterSelected() {
        showFilter()
    }

    func eventTeamStatSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: event.key,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
