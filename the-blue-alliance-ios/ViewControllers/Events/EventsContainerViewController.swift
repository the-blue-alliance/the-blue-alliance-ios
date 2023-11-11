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

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener

        year = statusService.currentSeason
        eventsViewController = WeekEventsViewController(year: year, dependencies: dependencies)

        super.init(viewControllers: [eventsViewController],
                   navigationTitle: EventsContainerViewController.eventsTitle(eventsViewController.weekEvent),
                   navigationSubtitle: ContainerViewController.yearSubtitle(year),
                   dependencies: dependencies)

        // TODO: We should be able to move this somewhere else and DRY this code
        title = RootType.events.title
        tabBarItem.image = RootType.events.icon

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Only show Search in container view on iPhone
        if UIDevice.isPhone {
            setupSearchController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Events: %ld", [year])
    }

    // MARK: - Private Methods

    private static func eventsTitle(_ event: Event?) -> String {
        if let event = event {
            return "\(event.weekString) Events"
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
        let yearSelectViewController = YearSelectViewController(year: year, years: Array(1992...statusService.maxSeason).reversed(), week: eventsViewController.weekEvent, dependencies: dependencies)
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
