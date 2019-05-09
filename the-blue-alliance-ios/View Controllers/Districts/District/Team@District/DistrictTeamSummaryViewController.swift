import CoreData
import Foundation
import TBAKit
import UIKit

protocol DistrictTeamSummaryViewControllerDelegate: AnyObject {
    func eventPointsSelected(_ eventPoints: DistrictEventPoints)
}

class DistrictTeamSummaryViewController: TBATableViewController {

    private let ranking: DistrictRanking

    weak var delegate: DistrictTeamSummaryViewControllerDelegate?

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<DistrictRanking> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.ranking = ranking

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)

        contextObserver.observeObject(object: ranking, state: .updated) { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Ranking, all of the event points, and Total Points
        return 2 + ranking.sortedEventPoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReverseSubtitleTableViewCell = self.tableView(tableView, reverseSubtitleCellAt: indexPath)
        if isEventPointsRow(row: indexPath.row) {
            // Event Points row
            let eventPoints = ranking.sortedEventPoints[indexPath.row - 1]
            cell.titleLabel.text = "\(eventPoints.eventKey!.event?.safeShortName ?? eventPoints.eventKey!.key!)"
            cell.subtitleLabel.text = "\(eventPoints.total!.stringValue) Points"
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == 0 {
            // Rank row
            cell.titleLabel.text = "District Rank"
            cell.subtitleLabel.text = "\(ranking.rank!.stringValue)\(ranking.rank!.intValue.suffix)"
        } else {
            // Total Points row
            cell.titleLabel.text = "Total Points"
            cell.subtitleLabel.text = "\(ranking.pointTotal!.stringValue) Points"
        }
        return cell
    }

    private func tableView(_ tableView: UITableView, reverseSubtitleCellAt indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        return tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isEventPointsRow(row: indexPath.row) {
            delegate?.eventPointsSelected(ranking.sortedEventPoints[indexPath.row - 1])
        }
    }

    // MARK: - Private Methods

    private func isEventPointsRow(row: Int) -> Bool {
        // If the row is less than the last event points row, it's an events points row
        // +1 for the ranking row
        return row > 0 && row < (ranking.sortedEventPoints.count + 1)
    }

}

extension DistrictTeamSummaryViewController: Refreshable {

    var refreshKey: String? {
        let key = ranking.getValue(\DistrictRanking.district!.key!)
        return "\(key)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh district team summary until the district is over
        let district = ranking.getValue(\DistrictRanking.district)
        let endDate = district?.endDate
        return endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return ranking.sortedEventPoints.count == 0
    }

    @objc func refresh() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchDistrictRankings(key: ranking.district!.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let rankings = try? result.get() {
                    let district = context.object(with: self.ranking.getValue(\DistrictRanking.district!).objectID) as! District
                    district.insert(rankings)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}
