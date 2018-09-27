import UIKit
import TBAKit
import CoreData

// TODO: This has a lot of modified functionality and needs a shit load of tests
class TeamViewController: ContainerViewController, Observable {

    typealias OptionType = Int

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

    // MARK: - Observable

    typealias ManagedType = Team
    lazy var contextObserver: CoreDataContextObserver<Team> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Init

    init(team: Team, urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
        self.team = team

        if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty {
            year = yearsParticipated.first
        }

        super.init(segmentedControlTitles: ["Info", "Events", "Media"],
                   persistentContainer: persistentContainer)

        navigationTitleDelegate = self

        contextObserver.observeObject(object: team, state: .updated) { [unowned self] (team, _) in
            if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty {
                self.year = yearsParticipated.first
            }

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }

        infoViewController = TeamInfoViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer)
        eventsViewController = EventsViewController(team: team, delegate: self, persistentContainer: persistentContainer)
        mediaViewController = TeamMediaCollectionViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer)
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

    private func updateInterface() {
        navigationTitle = "Team \(team.teamNumber)"

        if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, let year = year {
            navigationSubtitle = "▾ \(year)"
        } else {
            navigationSubtitle = "▾ ----"
        }
    }

    private func refreshYearsParticipated() {
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

    private func showSelectYear() {
        guard let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty else {
            return
        }

        let selectTableViewController = SelectTableViewController<TeamViewController>(current: year, options: yearsParticipated)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelectYear))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    @objc private func dismissSelectYear() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension TeamViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        showSelectYear()
    }

}

extension TeamViewController: SelectTableViewControllerDelegate {

    func optionSelected(_ option: Int) {
        year = option
    }

    func titleForOption(_ option: Int) -> String {
        return String(option)
    }

}

extension TeamViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
