import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class EventsContainerViewController: ContainerViewController {

    private(set) var myTBA: MyTBA
    private(set) var pasteboard: UIPasteboard?
    private(set) var photoLibrary: PHPhotoLibrary?
    private(set) var searchService: SearchService
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

    private(set) var year: Int
    private(set) var eventsViewController: WeekEventsViewController

    var searchController: UISearchController!

    // MARK: - Init

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener

        year = statusService.currentSeason
        eventsViewController = WeekEventsViewController(year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [eventsViewController],
                   navigationTitle: EventsContainerViewController.eventsTitle(eventsViewController.weekEvent),
                   navigationSubtitle: ContainerViewController.yearSubtitle(year),
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "Events"
        tabBarItem.image = UIImage.eventIcon

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self

        // TODO: REMOVE
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CC", style: .plain, target: self, action: #selector(pushCC))
    }

    // TODO: REMOVE
    @objc func pushCC() {
        let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: Match.predicate(key: "2019qcmo_qm1"))!
        let cc = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(cc, animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("events", parameters: ["year": NSNumber(value: year)])
    }

    // MARK: - Private Methods

    private static func eventsTitle(_ event: Event?) -> String {
        if let event = event, let weekString = event.weekString {
            return "\(weekString) Events"
        } else {
            return "---- Events"
        }
    }

    private func updateInterface() {
        navigationTitle = EventsContainerViewController.eventsTitle(eventsViewController.weekEvent)
        navigationSubtitle = ContainerViewController.yearSubtitle(year)
    }

}

extension EventsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let yearSelectViewController = YearSelectViewController(year: year, years: Array(1992...statusService.maxSeason).reversed(), week: eventsViewController.weekEvent, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        yearSelectViewController.delegate = self

        let nav = UINavigationController(rootViewController: yearSelectViewController)
        nav.modalPresentationStyle = .formSheet
        navigationController?.present(nav, animated: true, completion: nil)
    }

}

extension EventsContainerViewController: YearSelectViewControllerDelegate {

    func weekEventSelected(year: Int, weekEvent: Event) {
        self.year = year
        eventsViewController.weekEvent = weekEvent
    }

}

extension EventsContainerViewController: WeekEventsDelegate {

    func weekEventUpdated() {
        updateInterface()
    }

}

extension EventsContainerViewController: EventsViewControllerDelegate, SearchContainer, SearchContainerDelegate, SearchViewControllerDelegate {}
