import UIKit
import TBAKit
import CoreData

private let SelectYearSegue = "SelectYearSegue"

class TeamViewController: ContainerViewController, Observable {
    
    public var team: Team! {
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
    @IBOutlet internal var infoView: UIView!
    
    internal var eventsViewController: EventsTableViewController!
    @IBOutlet internal var eventsView: UIView!
    
    internal var mediaViewController: TeamMediaCollectionViewController!
    @IBOutlet internal var mediaView: UIView!
    
    // MARK: - Persistable
    
    override var persistentContainer: NSPersistentContainer! {
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Team \(team.teamNumber)"
        
        viewControllers = [infoViewController, eventsViewController, mediaViewController]
        containerViews = [infoView, eventsView, mediaView]
        
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
        navigationTitleLabel?.text = "Team \(team.teamNumber)"
        
        if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
    }
    
    func refreshYearsParticipated() {
        _ = TBAKit.sharedKit.fetchTeamYearsParticipated(key: team.key!, completion: { (years, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to fetch years participated - \(error.localizedDescription)")
                return
            }
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team

                if let years = years {
                    backgroundTeam.yearsParticipated = years.sorted().reversed()
                }
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh years participated - database error")
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue {
            let nav = segue.destination as! UINavigationController
            let selectTableViewController = SelectTableViewController<Int>()
            selectTableViewController.title = "Select Year"
            selectTableViewController.current = year
            selectTableViewController.options = team.yearsParticipated
            selectTableViewController.optionSelected = { [weak self] year in
                self?.year = year
            }
            selectTableViewController.optionString = { year in
                return String(year)
            }
            nav.viewControllers = [selectTableViewController]
        } else if segue.identifier == "TeamInfoEmbed" {
            infoViewController = segue.destination as? TeamInfoTableViewController
            infoViewController.team = team
        } else if segue.identifier == "TeamEventsEmbed" {
            eventsViewController = segue.destination as? EventsTableViewController
            eventsViewController.team = team
            eventsViewController.year = year
            eventsViewController.eventSelected = { [weak self] event in
                self?.performSegue(withIdentifier: "TeamAtEventSegue", sender: event)
            }
        } else if segue.identifier == "TeamMediaEmbed" {
            mediaViewController = segue.destination as? TeamMediaCollectionViewController
            mediaViewController.team = team
            mediaViewController.year = year
        } else if segue.identifier == "TeamAtEventSegue" {
            let event = sender as! Event
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }    
}
