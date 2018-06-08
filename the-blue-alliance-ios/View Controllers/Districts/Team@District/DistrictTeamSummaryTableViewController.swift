import UIKit
import CoreData
import TBAKit

class DistrictTeamSummaryTableViewController: TBATableViewController {

    public var ranking: DistrictRanking!
    private var sortedEventPoints: [DistrictEventPoints] {
        return (ranking!.eventPoints?.sortedArray(using: [NSSortDescriptor(key: "event.startDate", ascending: true)]) as? [DistrictEventPoints]) ?? []
    }
    var eventPointsSelected: ((DistrictEventPoints) -> Void)?

    // MARK: - Persistable

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            contextObserver.observeObject(object: ranking, state: .updated) { [weak self] (_, _) in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<DistrictRanking> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: ReverseSubtitleTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: ReverseSubtitleTableViewCell.reuseIdentifier)
    }

    // MARK: - Refresh

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistrictRankings(key: ranking.district!.key!, completion: { (rankings, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: self.ranking.district!.objectID) as! District

                let localRankings = rankings?.compactMap({ (modelRanking) -> DistrictRanking? in
                    let backgroundTeam = Team.insert(withKey: modelRanking.teamKey, in: backgroundContext)
                    return DistrictRanking.insert(with: modelRanking, for: backgroundDistrict, for: backgroundTeam, in: backgroundContext)
                })
                backgroundDistrict.rankings = Set(localRankings ?? []) as NSSet

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        return sortedEventPoints.count == 0
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReverseSubtitleTableViewCell.reuseIdentifier) as? ReverseSubtitleTableViewCell ?? ReverseSubtitleTableViewCell(style: .default, reuseIdentifier: ReverseSubtitleTableViewCell.reuseIdentifier)
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isEventPointsRow(row: indexPath.row), let eventPointsSelected = eventPointsSelected {
            eventPointsSelected(sortedEventPoints[indexPath.row - 1])
        }
    }

    // MARK: - Private Methods

    private func isEventPointsRow(row: Int) -> Bool {
        // If the row is less than the last event points row, it's an events points row
        // +1 for the ranking row
        return row > 0 && row < (sortedEventPoints.count + 1)
    }

}
