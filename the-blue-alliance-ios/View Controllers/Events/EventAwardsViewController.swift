import CoreData
import TBAKit
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private let event: Event
    private let teamKey: TeamKey?

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.teamKey = teamKey

        let awardsViewController = EventAwardsViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer)

        super.init(viewControllers: [awardsViewController],
                   persistentContainer: persistentContainer)

        navigationTitle = "Awards"
        if let teamKey = teamKey {
            navigationSubtitle = "Team \(teamKey.teamNumber) @ \(event.friendlyNameWithYear)"
        } else {
            navigationSubtitle = "@ \(event.friendlyNameWithYear)"
        }

        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        if teamKey == self.teamKey {
            return
        }
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey,
                                                                  event: event,
                                                                  persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamKeySelected(_ teamKey: TeamKey)
}

class EventAwardsViewController: TBATableViewController {

    private let event: Event
    private let teamKey: TeamKey?

    weak var delegate: EventAwardsViewControllerDelegate?
    private var dataSource: TableViewDataSource<Award, EventAwardsViewController>!

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.teamKey = teamKey

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "awardType", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Award>) {
        if let teamKey = teamKey {
            request.predicate = NSPredicate(format: "event == %@ AND (ANY recipients.teamKey == %@)", event, teamKey)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }

}

extension EventAwardsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: AwardTableViewCell, for object: Award, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.viewModel = AwardCellViewModel(award: object)
        cell.teamKeySelected = { [unowned self] (teamKey) in
            let teamKey = TeamKey.insert(withKey: teamKey, in: self.persistentContainer.viewContext)
            self.delegate?.teamKeySelected(teamKey)
        }
    }

}

extension EventAwardsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key!)_awards"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        if let awards = dataSource.fetchedResultsController.fetchedObjects, awards.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventAwards(key: event.key!, completion: { (awards, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event awards - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                if let awards = awards {
                    let localAwards = awards.map({ (modelAward) -> Award in
                        return Award.insert(with: modelAward, for: backgroundEvent, in: backgroundContext)
                    })
                    backgroundEvent.awards = Set(localAwards) as NSSet
                }

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

}

extension EventAwardsViewController: Stateful {

    var noDataText: String {
        return "No awards for \(teamKey != nil ? "team at event" : "event")"
    }

}
