import UIKit
import TBAKit
import CoreData

// TODO: This has a lot of modified functionality and needs a shit load of tests
class TeamViewController: ContainerViewController, Observable {

    private let team: Team
    var year: Int? {
        didSet {
            guard let year = year else {
                return
            }

            if eventsViewController.year != year {
                eventsViewController.year = year
            }
            if mediaViewController.year != year {
                mediaViewController.year = year
            }

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    private var infoViewController: TeamInfoViewController!
    private var eventsViewController: EventsViewController!
    private var mediaViewController: TeamMediaCollectionViewController!

    override var viewControllers: [ContainableViewController] {
        return [infoViewController, eventsViewController, mediaViewController]
    }

    // MARK: - Persistable

    override var persistentContainer: NSPersistentContainer {
        didSet {
            contextObserver.observeObject(object: team, state: .updated) { [weak self] (_, _) in
                self?.updateYear()

                DispatchQueue.main.async {
                    self?.updateInterface()
                }
            }
        }
    }

    // MARK: - Observable

    typealias ManagedType = Team
    lazy var contextObserver: CoreDataContextObserver<Team> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Init

    init(team: Team, persistentContainer: NSPersistentContainer) {
        self.team = team

        super.init(segmentedControlTitles: ["Info", "Events", "Media"],
                   persistentContainer: persistentContainer)

        // TODO: We should be able to do this before init, but we can't
        updateYear()

        infoViewController = TeamInfoViewController(team: team, persistentContainer: persistentContainer)
        eventsViewController = EventsViewController(team: team, delegate: self, persistentContainer: persistentContainer)
        mediaViewController = TeamMediaCollectionViewController(team: team, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Team \(team.teamNumber)"

        refreshYearsParticipated()
        updateInterface()
    }

    // MARK: - Private

    func updateYear() {
        guard let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, year == nil else {
            return
        }
        year = yearsParticipated.first
    }

    func updateInterface() {
        navigationTitle = "Team \(team.teamNumber)"

        if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, let year = year {
            navigationSubtitle = "▾ \(year)"
        } else {
            navigationSubtitle = "▾ ----"
        }
    }

    func refreshYearsParticipated() {
        _ = TBAKit.sharedKit.fetchTeamYearsParticipated(key: team.key!, completion: { (years, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to fetch years participated - \(error.localizedDescription)")
                return
            }
            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team

                if let years = years {
                    backgroundTeam.yearsParticipated = years.sorted().reversed()
                }

                backgroundContext.saveContext()
            })
        })
    }

    /*

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue {
            if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty {
                return true
            }
            return false
        }
        return true
    }

    */

}

extension TeamViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
