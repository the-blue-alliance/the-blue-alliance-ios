import Foundation
import TBAAPI
import UIKit

protocol DistrictTeamSummaryViewControllerDelegate: AnyObject {
    func eventPointsSelected(eventKey: String)
}

class DistrictTeamSummaryViewController: TBATableViewController, Refreshable, Stateful {

    private let teamKey: String
    private let districtKey: String
    private var ranking: DistrictRanking
    private var eventsByKey: [String: Event] = [:]

    weak var delegate: DistrictTeamSummaryViewControllerDelegate?

    // MARK: Init

    init(ranking: DistrictRanking, districtKey: String, dependencies: Dependencies) {
        self.ranking = ranking
        self.teamKey = ranking.teamKey
        self.districtKey = districtKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
    }

    // MARK: - Table view data source

    private var eventPoints: [DistrictRanking.EventPointsPayloadPayload] {
        ranking.eventPoints ?? []
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Ranking + per-event rows + Total Points
        return 2 + eventPoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        if isEventPointsRow(row: indexPath.row) {
            let points = eventPoints[indexPath.row - 1]
            cell.titleLabel.text = eventsByKey[points.eventKey]?.safeShortName ?? points.eventKey
            cell.subtitleLabel.text = "\(points.total) Points"
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == 0 {
            cell.titleLabel.text = "District Rank"
            cell.subtitleLabel.text = "\(ranking.rank)\(ranking.rank.suffix)"
            cell.selectionStyle = .none
            cell.accessoryType = .none
        } else {
            cell.titleLabel.text = "Total Points"
            cell.subtitleLabel.text = "\(ranking.pointTotal) Points"
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isEventPointsRow(row: indexPath.row) {
            let points = eventPoints[indexPath.row - 1]
            delegate?.eventPointsSelected(eventKey: points.eventKey)
        }
    }

    private func isEventPointsRow(row: Int) -> Bool {
        return row > 0 && row < (eventPoints.count + 1)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { eventPoints.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let rankingsHandle = Task {
                try await self.dependencies.api.districtRankings(key: self.districtKey)
            }
            let eventsHandle = Task {
                try? await self.dependencies.api.districtEvents(key: self.districtKey)
            }

            // Persist events before awaiting rankings so a rankings failure
            // doesn't discard a successful events response — the next refresh
            // that succeeds on rankings will render using this event map.
            let events = await eventsHandle.value ?? []
            self.eventsByKey = Dictionary(uniqueKeysWithValues: events.map { ($0.key, $0) })

            let fetched = try await rankingsHandle.value
            if let updated = fetched?.first(where: { $0.teamKey == self.teamKey }) {
                self.ranking = updated
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No summary for team at district" }
}
