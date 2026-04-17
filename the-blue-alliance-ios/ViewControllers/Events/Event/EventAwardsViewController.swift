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

        let awardsViewController = EventAwardsViewController(eventKey: event.key, teamKey: teamKey, dependencies: dependencies)

        super.init(viewControllers: [awardsViewController],
                   navigationTitle: "Awards",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   dependencies: dependencies)

        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: event.key, year: event.year, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

class EventAwardsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: EventAwardsViewControllerDelegate?

    private let eventKey: String
    private let teamKey: String?

    private var dataSource: TableViewDataSource<String, Award>!
    private var awards: [Award] = []

    // MARK: - Init

    init(eventKey: String, teamKey: String? = nil, dependencies: Dependencies) {
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
        dataSource = TableViewDataSource<String, Award>(tableView: tableView) { [weak self] tableView, indexPath, award in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AwardTableViewCell
            cell.selectionStyle = .none
            cell.viewModel = AwardCellViewModel(award: award)
            cell.teamKeySelected = { [weak self] (teamKey) in
                self?.delegate?.teamSelected(teamKey: teamKey)
            }
            _ = self
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
            let fetched = try await self.dependencies.api.eventAwards(key: self.eventKey)
            self.applyAwards(fetched)
        }
    }

    // MARK: - Stateful

    var noDataText: String? {
        "No awards for \(teamKey != nil ? "team at event" : "event")"
    }
}
