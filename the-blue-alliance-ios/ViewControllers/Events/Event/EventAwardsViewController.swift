import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private(set) var event: Event

    // MARK: - Init

    init(event: Event, teamKey: String? = nil, dependencies: Dependencies) {
        self.event = event

        let awardsViewController = EventAwardsViewController(
            eventKey: event.key,
            teamKey: teamKey,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [awardsViewController],
            navigationTitle: "Awards",
            navigationSubtitle: "@ \(event.friendlyNameWithYear)",
            dependencies: dependencies
        )

        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event Awards: \(event.key)")
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: event.key,
            year: event.year,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

class EventAwardsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: EventAwardsViewControllerDelegate?

    private let eventKey: EventKey
    private let teamKey: String?

    private var dataSource: TableViewDataSource<String, Award>!
    private var awards: [Award] = []
    private var teamsByKey: [String: TeamSimple] = [:]

    // MARK: - Init

    init(eventKey: EventKey, teamKey: String? = nil, dependencies: Dependencies) {
        self.eventKey = eventKey
        self.teamKey = teamKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(AwardTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, Award>(tableView: tableView) {
            [weak self] tableView, indexPath, award in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AwardTableViewCell
            cell.selectionStyle = .none
            cell.viewModel = AwardCellViewModel(award: award, teamsByKey: self?.teamsByKey ?? [:])
            cell.teamKeySelected = { [weak self] (teamKey) in
                self?.delegate?.teamSelected(teamKey: teamKey)
            }
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func applyAwards(_ awards: [Award]) {
        let filtered: [Award]
        if let teamKey {
            filtered = awards.filter { $0.recipientList.contains(where: { $0.teamKey == teamKey }) }
        } else {
            filtered = awards
        }
        let sorted = filtered.sorted { $0.awardType < $1.awardType }
        self.awards = sorted

        var snapshot = NSDiffableDataSourceSnapshot<String, Award>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { awards.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let awardsHandle = Task {
                try await self.dependencies.api.eventAwards(key: self.eventKey)
            }
            let teamsHandle = Task {
                try? await self.dependencies.api.eventTeamsSimple(key: self.eventKey)
            }

            let teams = await teamsHandle.value ?? []
            self.teamsByKey = Dictionary(uniqueKeysWithValues: teams.map { ($0.key, $0) })

            self.applyAwards(try await awardsHandle.value)
        }
    }

    // MARK: - Stateful

    var noDataText: String? {
        "No awards for \(teamKey != nil ? "team at event" : "event")"
    }
}
