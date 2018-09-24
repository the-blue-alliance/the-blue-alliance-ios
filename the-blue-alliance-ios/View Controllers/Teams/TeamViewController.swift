import UIKit
import TBAKit
import CoreData

private let SelectYearSegue = "SelectYearSegue"

class TeamViewController: ContainerViewController, Observable {

    public var team: Team {
        didSet {
            updateYear()
        }
    }
    var year: Int? {
        didSet {
            // These need to be optional since we might not have our views setup when hitting this
            // if we're being called from updateYear from TeamsContainerViewController segue (storyboards suck)
            if let year = year, eventsViewController?.year != year {
                eventsViewController?.year = year
            }
            if let year = year, mediaViewController?.year != year {
                mediaViewController?.year = year
            }

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    // Only refresh years participated once on appear
    private lazy var refreshYearsParticipatedOnce: Void = { [weak self] in
        self?.refreshYearsParticipated()
    }()

    internal var infoViewController: TeamInfoTableViewController!
    internal var eventsViewController: EventsTableViewController!
    internal var mediaViewController: TeamMediaCollectionViewController!

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

        let infoViewController = TeamInfoTableViewController(team: team, persistentContainer: persistentContainer)

        let eventsViewController = EventsTableViewController(team: team, eventSelected: { [unowned self] (event) in
            let teamAtEventViewController = TeamAtEventViewController(team: self.team, event: event, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
            }, persistentContainer: persistentContainer)

        let mediaViewController = TeamMediaCollectionViewController(team: team, persistentContainer: persistentContainer)

        viewControllers = [infoViewController, eventsViewController, mediaViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Team \(team.teamNumber)"

        // TODO: Why the fuck do we have this again?
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }

        updateInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        _ = refreshYearsParticipatedOnce
    }

    // MARK: - Private

    func updateYear() {
        guard let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, year == nil else {
            return
        }
        year = yearsParticipated.first
    }

    func updateInterface() {
        navigationTitleLabel.text = "Team \(team.teamNumber)"

        if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, let year = year {
            navigationDetailLabel.text = "▾ \(year)"
        } else {
            navigationDetailLabel.text = "▾ ----"
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

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue {
            if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty {
                return true
            }
            return false
        }
        return true
    }

}
