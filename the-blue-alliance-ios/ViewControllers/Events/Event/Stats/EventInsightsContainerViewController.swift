import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAAPI
import TBAData
import TBAKit
import UIKit

class EventInsightsContainerViewController: ContainerViewController {

    private(set) var event: Components.Schemas.Event
    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private let teamStatsViewController: EventTeamStatsTableViewController

    // MARK: - Init

    init(event: Components.Schemas.Event, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        teamStatsViewController = EventTeamStatsTableViewController(eventKey: event.key, dependencies: dependencies)

        var eventStatsViewController: EventInsightsViewController?
        // Only show event insights if year is 2016 or onward
        var titles = ["Team Stats"]
        if event.year >= 2016 {
            titles.append("Event Insights")
            eventStatsViewController = EventInsightsViewController(eventKey: event.key, year: event.year, dependencies: dependencies)
        }

        super.init(viewControllers: [teamStatsViewController, eventStatsViewController].compactMap({ $0 }),
                   navigationTitle: "Stats",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   segmentedControlTitles: titles,
                   dependencies: dependencies)

        teamStatsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Event Stats: %@", [event.key])
    }

    // MARK: - Private Methods

    private func showFilter() {
        let selectTableViewController = SelectTableViewController<EventInsightsContainerViewController>(current: teamStatsViewController.filter, options: EventTeamStatFilter.allCases, dependencies: dependencies)
        selectTableViewController.title = "Sort stats by"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFilter))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    // MARK: - Interface Actions

    @objc private func dismissFilter() {
        navigationController?.dismiss(animated: true, completion: nil)
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
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: event.key, year: event.year, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
