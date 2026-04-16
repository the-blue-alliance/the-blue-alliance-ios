import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private(set) var event: Event
    private let myTBA: MyTBA
    private let myTBAStores: MyTBAStores
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(event: Event, teamKey: String? = nil, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

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

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Event Awards: %@", [event.key])
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: event.key, year: event.year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
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
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Refreshable

    var refreshKey: String? { "\(eventKey)_awards" }
    var automaticRefreshInterval: DateComponents? { nil }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { awards.isEmpty }

    @objc func refresh() {
        Task { @MainActor in
            do {
                let fetched = try await dependencies.api.eventAwards(key: eventKey)
                applyAwards(fetched)
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? {
        "No awards for \(teamKey != nil ? "team at event" : "event")"
    }
}
