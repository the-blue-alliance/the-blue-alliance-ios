import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

class DistrictBreakdownViewController: TBATableViewController, Observable {

    private let ranking: DistrictRanking

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<DistrictRanking> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(ranking: DistrictRanking, dependencies: Dependencies) {
        self.ranking = ranking

        super.init(dependencies: dependencies)
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
            points = eventPoints.qualPoints
        case 1:
            pointsType = "Elimination"
            points = eventPoints.elimPoints
        case 2:
            pointsType = "Alliance"
            points = eventPoints.alliancePoints
        case 3:
            pointsType = "Award"
            points = eventPoints.awardPoints
        case 4:
            pointsType = "Total"
            points = eventPoints.total
        default: break
        }

        cell.titleLabel.text = "\(pointsType) Points"
        cell.subtitleLabel.text = "\(points) Points"

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let eventPoints = ranking.sortedEventPoints[section]
        return eventPoints.event.name ?? eventPoints.event.key
    }

}

extension DistrictBreakdownViewController: Refreshable {

    var refreshKey: String? {
        return "\(ranking.district.key)_breakdown"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team's district breakdown until district is over
        return ranking.district.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        // This should never fire
        return ranking.sortedEventPoints.count == 0
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchDistrictRankings(key: ranking.district.key) { [self] (result, notModified) in
            guard case .success(let rankings) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({ [unowned self] in
                let district = context.object(with: self.ranking.district.objectID) as! District
                district.insert(rankings)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: operation!)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension DistrictBreakdownViewController: Stateful {

    var noDataText: String? {
        return "No district points for team"
    }

}
