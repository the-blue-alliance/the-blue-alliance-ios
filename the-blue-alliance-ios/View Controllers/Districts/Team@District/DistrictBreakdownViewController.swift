import Foundation
import UIKit
import CoreData
import TBAKit

class DistrictBreakdownViewController: TBATableViewController, Observable {

    private let ranking: DistrictRanking
    private let sortedEventPoints: [DistrictEventPoints]

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<DistrictRanking> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer) {
        self.ranking = ranking

        sortedEventPoints = (ranking.eventPoints?.sortedArray(using: [NSSortDescriptor(key: "event.startDate", ascending: true)]) as? [DistrictEventPoints]) ?? []

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


    // MARK: Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = sortedEventPoints.count
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
        let eventPoints = sortedEventPoints[indexPath.section]

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
        let eventPoints = sortedEventPoints[section]
        return eventPoints.event!.name
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
        return sortedEventPoints.count == 0
    }

    @objc func refresh() {
        removeNoDataView()

        var rankingsRequest: URLSessionDataTask?
        rankingsRequest = TBAKit.sharedKit.fetchDistrictRankings(key: ranking.district!.key!, completion: { (rankings, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team district breakdown - \(error.localizedDescription)")
                self.removeRequest(request: rankingsRequest!)
                return
            } else {
                self.markRefreshSuccessful()
            }

            // Might as well insert them all... we just need to only fetch
            guard let ranking = rankings?.first(where: { $0.teamKey == self.ranking.teamKey!.key! }) else {
                self.removeRequest(request: rankingsRequest!)
                return
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let eventKeys = Set(ranking.eventPoints.map({ $0.eventKey }))
                let eventlessKeys = Set(eventKeys.compactMap({ (eventKey) -> String? in
                    let predicate = NSPredicate(format: "key == %@", eventKey)
                    let event = Event.findOrFetch(in: backgroundContext, matching: predicate)
                    return event == nil ? eventKey : nil
                }))

                // Fetch all the events we don't currently have
                // Wait until fetches are done to insert rankings
                let dispatchGroup = DispatchGroup()
                for eventKey in eventlessKeys {
                    dispatchGroup.enter()
                    self.fetchEvent(eventKey: eventKey, completion: { (_) in
                        dispatchGroup.leave()
                    })
                }
                dispatchGroup.wait()

                if let rankings = rankings {
                    DistrictRanking.insert(rankings, district: self.ranking.district!, in: backgroundContext)
                    backgroundContext.saveOrRollback()
                }
                self.removeRequest(request: rankingsRequest!)
            })
        })
        addRequest(request: rankingsRequest!)
    }

    @discardableResult
    private func fetchEvent(eventKey: String, completion: @escaping (_ success: Bool) -> Void) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchEvent(key: eventKey, completion: { (modelEvent, error) in
            if error != nil {
                completion(false)
                return
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                if let modelEvent = modelEvent {
                    Event.insert(with: modelEvent, in: backgroundContext)
                }
                backgroundContext.saveOrRollback()
                completion(true)
            })
        })
    }

}

extension DistrictBreakdownViewController: Stateful {

    var noDataText: String {
        return "No district points for team"
    }

}
