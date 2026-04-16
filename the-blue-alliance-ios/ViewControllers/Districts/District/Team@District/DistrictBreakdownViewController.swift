import Foundation
import TBAAPI
import UIKit

class DistrictBreakdownViewController: TBATableViewController, Refreshable, Stateful {

    private let teamKey: String
    private let districtKey: String
    private var ranking: Components.Schemas.DistrictRanking

    // MARK: - Init

    init(ranking: Components.Schemas.DistrictRanking, districtKey: String, dependencies: Dependencies) {
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

    // MARK: Table View Data Source

    private var eventPoints: [Components.Schemas.DistrictRanking.EventPointsPayloadPayload] {
        ranking.eventPoints ?? []
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = eventPoints.count
        if sections == 0 {
            showNoDataView()
        } else {
            removeNoDataView()
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Qual Points, Elim Points, Alliance Points, Award Points, Total Points
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        let points = eventPoints[indexPath.section]

        let (pointsType, pointsValue): (String, Int) = {
            switch indexPath.row {
            case 0: return ("Qualification", points.qualPoints)
            case 1: return ("Elimination", points.elimPoints)
            case 2: return ("Alliance", points.alliancePoints)
            case 3: return ("Award", points.awardPoints)
            case 4: return ("Total", points.total)
            default: return ("", 0)
            }
        }()

        cell.titleLabel.text = "\(pointsType) Points"
        cell.subtitleLabel.text = "\(pointsValue) Points"

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        eventPoints[section].eventKey
    }

    // MARK: - Refreshable

    var refreshKey: String? { "\(districtKey)_breakdown" }
    var automaticRefreshInterval: DateComponents? { DateComponents(day: 1) }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { eventPoints.isEmpty }

    @objc func refresh() {
        Task { @MainActor in
            do {
                let fetched = try await dependencies.api.districtRankings(key: districtKey)
                if let updated = fetched.first(where: { $0.teamKey == teamKey }) {
                    ranking = updated
                    tableView.reloadData()
                }
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No district points for team" }
}
