import BFRImageViewer
import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class TeamViewController: MyTBAContainerViewController, Observable {

    private(set) var team: Team
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var infoViewController: TeamInfoViewController
    private(set) var eventsViewController: TeamEventsViewController
    private(set) var mediaViewController: TeamMediaCollectionViewController

    override var subscribableModel: MyTBASubscribable {
        return team
    }

    private var year: Int? {
        didSet {
            if let year = year {
                if eventsViewController.year != year {
                    eventsViewController.year = year
                }
                if mediaViewController.year != year {
                    mediaViewController.year = year
                }
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

    init(team: Team, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener
        self.year = TeamViewController.latestYear(currentSeason: statusService.currentSeason, years: team.yearsParticipated, in: persistentContainer.viewContext)

        infoViewController = TeamInfoViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        eventsViewController = TeamEventsViewController(team: team, year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        mediaViewController = TeamMediaCollectionViewController(team: team, year: year, pasteboard: pasteboard, photoLibrary: photoLibrary, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(
            viewControllers: [infoViewController, eventsViewController, mediaViewController],
            navigationTitle: team.teamNumberNickname,
            navigationSubtitle: ContainerViewController.yearSubtitle(year),
            segmentedControlTitles: ["Info", "Events", "Media"],
            myTBA: myTBA,
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        mediaViewController.delegate = self

        setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("team", parameters: ["team": team.key])
    }

    // MARK: - Private

    private func setupObservers() {
        contextObserver.observeObject(object: team, state: .updated) { [weak self] (team, _) in
            guard let self = self else {
                return
            }
            guard let context = team.managedObjectContext else {
                fatalError("No context for Team.")
            }
            if self.year == nil {
                self.year = TeamViewController.latestYear(
                    currentSeason: self.statusService.currentSeason,
                    years: team.yearsParticipated,
                    in: context
                )
            } else {
                self.updateInterface()
            }
        }
    }

    private static func latestYear(currentSeason: Int, years: [Int]?, in context: NSManagedObjectContext) -> Int? {
        if let years = years, !years.isEmpty {
            // Limit default year set to be <= currentSeason
            let latestYear = years.first!
            if latestYear > currentSeason, years.count > 1 {
                // Find the next year before the current season
                return years.first(where: { $0 <= currentSeason })
            } else {
                // Otherwise, the first year is fine (for new teams)
                return years.first
            }
        }
        return nil
    }

    private func updateInterface() {
        navigationSubtitle = ContainerViewController.yearSubtitle(year)
    }

    private func showSelectYear() {
        guard let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty else {
            return
        }

        let selectTableViewController = SelectTableViewController<TeamViewController>(current: year, options: yearsParticipated, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
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
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension TeamViewController: TeamMediaCollectionViewControllerDelegate {

    func mediaSelected(_ media: TeamMedia) {
        if let imageViewController = TeamMediaImageViewController.forMedia(media: media) {
            DispatchQueue.main.async {
                self.present(imageViewController, animated: true)
            }
        }
    }

}

class TeamMediaImageViewController: BFRImageViewController {

    public static func forMedia(media: TeamMedia, peek: Bool = false) -> TeamMediaImageViewController? {
        // TODO: Support showing multiple images
        var imageViewController: TeamMediaImageViewController?
        if let image = media.image {
            let images = [image]
            imageViewController = peek ?
                TeamMediaImageViewController(forPeekWithImageSource: images) :
                TeamMediaImageViewController(imageSource: images)
        } else if let url = media.imageDirectURL {
            let urls = [url]
            imageViewController = peek ?
                TeamMediaImageViewController(forPeekWithImageSource: urls) :
                TeamMediaImageViewController(imageSource: urls)
        }
        imageViewController?.modalPresentationStyle = .fullScreen
        imageViewController?.showDoneButtonOnLeft = false
        return imageViewController
    }

}
