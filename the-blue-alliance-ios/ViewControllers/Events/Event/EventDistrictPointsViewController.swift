import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAAPI
import TBAData
import TBAKit
import UIKit

class EventDistrictPointsContainerViewController: ContainerViewController {

    private(set) var event: Components.Schemas.Event
    private let myTBA: MyTBA
    private let myTBAStores: MyTBAStores
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(event: Components.Schemas.Event, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        let districtPointsViewController = EventDistrictPointsViewController(eventKey: event.key, dependencies: dependencies)

        super.init(viewControllers: [districtPointsViewController],
                   navigationTitle: "District Points",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   dependencies: dependencies)

        districtPointsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Event District Points: %@", [event.key])
    }

}

extension EventDistrictPointsContainerViewController: EventDistrictPointsViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: event.key, year: event.year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventDistrictPointsViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

private struct TeamDistrictPointsRow: Hashable {
    let teamKey: String
    let total: Int
}

private class EventDistrictPointsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: EventDistrictPointsViewControllerDelegate?

    private let eventKey: String

    private var dataSource: TableViewDataSource<String, TeamDistrictPointsRow>!
    private var rows: [TeamDistrictPointsRow] = []

    // MARK: - Init

    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.teamSelected(teamKey: row.teamKey)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, TeamDistrictPointsRow>(tableView: tableView) { tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(rank: "Rank \(indexPath.row + 1)",
                                                  apiTeamKey: row.teamKey,
                                                  points: row.total)
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func apply(points: Components.Schemas.EventDistrictPoints?) {
        let sortedRows: [TeamDistrictPointsRow]
        if let dict = points?.points.additionalProperties {
            sortedRows = dict
                .map { TeamDistrictPointsRow(teamKey: $0.key, total: $0.value.total) }
                .sorted { $0.total > $1.total }
        } else {
            sortedRows = []
        }
        self.rows = sortedRows

        var snapshot = NSDiffableDataSourceSnapshot<String, TeamDistrictPointsRow>()
        snapshot.appendSections([""])
        snapshot.appendItems(sortedRows, toSection: "")
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Refreshable

    var refreshKey: String? { "\(eventKey)_district_points" }
    var automaticRefreshInterval: DateComponents? { nil }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { rows.isEmpty }

    @objc func refresh() {
        Task { @MainActor in
            do {
                let response = try await dependencies.api.eventDistrictPoints(key: eventKey)
                apply(points: response)
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No district points for event" }
}
