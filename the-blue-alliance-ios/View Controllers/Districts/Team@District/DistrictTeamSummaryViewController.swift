import Foundation
import UIKit
import CoreData
import TBAKit

protocol DistrictTeamSummaryViewControllerDelegate: AnyObject {
    func eventPointsSelected(_ eventPoints: DistrictEventPoints)
}

class DistrictTeamSummaryViewController: TBATableViewController, Refreshable {

    private let ranking: DistrictRanking

    weak var delegate: DistrictTeamSummaryViewControllerDelegate?

    private let sortedEventPoints: [DistrictEventPoints]

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<DistrictRanking> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer) {
        self.ranking = ranking

        sortedEventPoints = ranking.eventPoints?.sortedArray(using: [NSSortDescriptor(key: "event.startDate", ascending: true)]) as? [DistrictEventPoints] ?? []

        super.init(persistentContainer: persistentContainer)

        contextObserver.observeObject(object: ranking, state: .updated) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
    }

    // MARK: - Refresh

    var refreshKey: String? {
        return "\(ranking.district!.key!)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh district team summary until the district is over
        return ranking.district?.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return sortedEventPoints.count == 0
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistrictRankings(key: ranking.district!.key!, completion: { (rankings, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: self.ranking.district!.objectID) as! District
                rankings?.forEach({ (modelRanking) in
                    let backgroundTeam = Team.insert(withKey: modelRanking.teamKey, in: backgroundContext)
                    DistrictRanking.insert(with: modelRanking, for: backgroundDistrict, for: backgroundTeam, in: backgroundContext)
                })

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Ranking, all of the event points, and Total Points
        return 2 + sortedEventPoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReverseSubtitleTableViewCell = self.tableView(tableView, reverseSubtitleCellAt: indexPath)
        if isEventPointsRow(row: indexPath.row) {
            // Event Points row
            let eventPoints = sortedEventPoints[indexPath.row - 1]
            cell.titleLabel.text = "\(eventPoints.event!.safeShortName)"
            cell.subtitleLabel.text = "\(eventPoints.total) Points"
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == 0 {
            // Rank row
            cell.titleLabel.text = "District Rank"
            cell.subtitleLabel.text = "\(ranking.rank)\(ranking.rank.suffix())"
        } else {
            // Total Points row
            cell.titleLabel.text = "Total Points"
            cell.subtitleLabel.text = "\(ranking.pointTotal) Points"
        }
        return cell
    }

    private func tableView(_ tableView: UITableView, reverseSubtitleCellAt indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        return tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isEventPointsRow(row: indexPath.row) {
            delegate?.eventPointsSelected(sortedEventPoints[indexPath.row - 1])
        }
    }

    // MARK: - Private Methods

    private func isEventPointsRow(row: Int) -> Bool {
        // If the row is less than the last event points row, it's an events points row
        // +1 for the ranking row
        return row > 0 && row < (sortedEventPoints.count + 1)
    }

}
