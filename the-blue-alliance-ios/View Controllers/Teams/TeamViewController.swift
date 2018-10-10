import UIKit
import TBAKit
import CoreData
import FirebaseRemoteConfig

class TeamViewController: ContainerViewController, Observable {

    private let team: Team

    private let eventsViewController: TeamEventsViewController
    // private let mediaViewController: TeamMediaCollectionViewController

    private var year: Int? {
        didSet {
            if let year = year {
                if eventsViewController.year != year {
                    eventsViewController.year = year
                }
                /*
                if mediaViewController.year != year {
                    mediaViewController.year = year
                }
                */
            }

            updateInterface()
        }
    }

    // MARK: - Observable

    typealias ManagedType = Team
    lazy var contextObserver: CoreDataContextObserver<Team> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Init

    init(team: Team, remoteConfig: RemoteConfig, urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.year = TeamViewController.latestYear(remoteConfig: remoteConfig, years: team.yearsParticipated)

        let infoViewController = TeamInfoViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer)
        eventsViewController = TeamEventsViewController(team: team, year: year, persistentContainer: persistentContainer)
        // mediaViewController = TeamMediaCollectionViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer)

        super.init(viewControllers: [infoViewController, eventsViewController],
                   segmentedControlTitles: ["Info", "Events"],
                   persistentContainer: persistentContainer)

        updateInterface()

        navigationTitleDelegate = self
        eventsViewController.delegate = self

        contextObserver.observeObject(object: team, state: .updated) { [unowned self] (team, _) in
            if self.year == nil {
                self.year = TeamViewController.latestYear(remoteConfig: remoteConfig, years: team.yearsParticipated)
            } else {
                self.updateInterface()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshYearsParticipated()
    }

    // MARK: - Private

    private static func latestYear(remoteConfig: RemoteConfig, years: [Int]?) -> Int? {
        if let years = years, !years.isEmpty {
            // Limit default year set to be <= currentSeason
            let latestYear = years.first!
            if latestYear > remoteConfig.currentSeason, years.count > 1 {
                // Find the next year before the current season
                return years.first(where: { $0 <= remoteConfig.currentSeason })
            } else {
                // Otherwise, the first year is fine (for new teams)
                return years.first
            }
        }
        return nil
    }

    private func updateInterface() {
        navigationTitle = "Team \(team.teamNumber)"

        if let year = year {
            navigationSubtitle = "▾ \(year)"
        } else {
            navigationSubtitle = "▾ ----"
        }
    }

    private func refreshYearsParticipated() {
        TBAKit.sharedKit.fetchTeamYearsParticipated(key: team.key!, completion: { (years, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to fetch years participated - \(error.localizedDescription)")
                return
            }
            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team

                if let years = years {
                    backgroundTeam.yearsParticipated = years.sorted().reversed()
                }

                backgroundContext.saveOrRollback()
            })
        })
    }

    private func showSelectYear() {
        guard let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty else {
            return
        }

        let selectTableViewController = SelectTableViewController<TeamViewController>(current: year, options: yearsParticipated, persistentContainer: persistentContainer)
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

    typealias OptionType = Int

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
