import Foundation
import UIKit
import CoreData

class DistrictBreakdownViewController: TBATableViewController, Observable {

    private let ranking: DistrictRanking

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<DistrictRanking> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.ranking = ranking

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)

        contextObserver.observeObject(object: ranking, state: .updated) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


    // MARK: Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = ranking.sortedEventPoints.count
        if sections == 0 {
            showNoDataView()
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Qual Points, Elim Points, Alliance Points, Award Points, Total Points
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        let eventPoints = ranking.sortedEventPoints[indexPath.section]

        var pointsType = ""
        var points = 0

        switch indexPath.row {
        case 0:
            pointsType = "Qualification"
            points = eventPoints.qualPoints!.intValue
        case 1:
            pointsType = "Elimination"
            points = eventPoints.elimPoints!.intValue
        case 2:
            pointsType = "Alliance"
            points = eventPoints.alliancePoints!.intValue
        case 3:
            pointsType = "Award"
            points = eventPoints.awardPoints!.intValue
        case 4:
            pointsType = "Total"
            points = eventPoints.total!.intValue
        default: break
        }

        cell.titleLabel.text = "\(pointsType) Points"
        cell.subtitleLabel.text = "\(points) Points"

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let eventPoints = ranking.sortedEventPoints[section]
        return eventPoints.eventKey!.event?.name ?? eventPoints.eventKey!.key!
    }

}

extension DistrictBreakdownViewController: Refreshable {

    var refreshKey: String? {
        return "\(ranking.district!.key!)_breakdown"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team's district breakdown until district is over
        return ranking.district?.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        // This should never fire
        return ranking.sortedEventPoints.count == 0
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchDistrictRankings(key: ranking.district!.key!, completion: { (rankings, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team district breakdown - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let rankings = rankings {
                    let district = backgroundContext.object(with: self.ranking.district!.objectID) as! District
                    district.insert(rankings)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

}

extension DistrictBreakdownViewController: Stateful {

    var noDataText: String {
        return "No district points for team"
    }

}
