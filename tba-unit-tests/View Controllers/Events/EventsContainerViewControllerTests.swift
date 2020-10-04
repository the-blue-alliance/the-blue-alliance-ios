import XCTest
@testable import The_Blue_Alliance

class EventsContainerViewControllerTests: TBATestCase {

    var navigationController: MockNavigationController!
    var eventsContainerViewController: EventsContainerViewController!

    override func setUp() {
        super.setUp()

        eventsContainerViewController = EventsContainerViewController(myTBA: myTBA,
                                                                      searchService: searchService,
                                                                      statusService: statusService,
                                                                      urlOpener: urlOpener,
                                                                      dependencies: dependencies)
        eventsContainerViewController.viewDidLoad()

        navigationController = MockNavigationController(rootViewController: eventsContainerViewController)
    }

    override func tearDown() {
        navigationController = nil
        eventsContainerViewController = nil

        super.tearDown()
    }

    func test_delegates() {
        XCTAssertNotNil(eventsContainerViewController.navigationTitleDelegate)
        XCTAssertNotNil(eventsContainerViewController.eventsViewController.delegate)
        XCTAssertNotNil(eventsContainerViewController.eventsViewController.weekEventsDelegate)
    }

    func test_title() {
        XCTAssertEqual(eventsContainerViewController.title, "Events")

        XCTAssertEqual(eventsContainerViewController.navigationTitle, "---- Events")
        XCTAssertEqual(eventsContainerViewController.navigationSubtitle, "▾ 2015")
    }

    func test_tabBar() {
        XCTAssertEqual(eventsContainerViewController.tabBarItem.title, "Events")
    }

    func test_showsWeekEvents() {
        XCTAssert(eventsContainerViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is WeekEventsViewController
        }))
    }

    func test_years_showYearSelect() {
        let event = insertEvent(year: 2014)
        eventsContainerViewController.weekEventSelected(year: 2014, weekEvent: event)
        eventsContainerViewController.navigationTitleTapped()

        navigationController.presentCalled = {
            XCTAssert($0 is UINavigationController)
            let nav = $0 as! UINavigationController
            XCTAssert(nav.viewControllers.first is YearSelectViewController)
            let yearSelectViewController = nav.viewControllers.first as! YearSelectViewController
            XCTAssertEqual(yearSelectViewController.year, 2014)
            XCTAssertEqual(yearSelectViewController.week, event)
        }
    }

    func test_years_eventWeekSelected() {
        let event = insertEvent(year: 2014)
        eventsContainerViewController.weekEventSelected(year: 2014, weekEvent: event)

        XCTAssertEqual(eventsContainerViewController.year, 2014)
        XCTAssertEqual(eventsContainerViewController.eventsViewController.weekEvent, event)
    }

    func test_eventWeeksUpdated() {
        let event = insertEvent()

        eventsContainerViewController.eventsViewController.weekEvent = event
        eventsContainerViewController.weekEventUpdated()

        XCTAssertEqual(eventsContainerViewController.navigationTitle, "Week 4 Events")
        XCTAssertEqual(eventsContainerViewController.navigationSubtitle, "▾ 2015")
    }

    func test_events_pushEvent() {
        let event = insertEvent()

        eventsContainerViewController.eventSelected(event)
        XCTAssert(navigationController.pushedViewController is EventViewController)

        let eventViewController = navigationController.pushedViewController as! EventViewController
        XCTAssertEqual(eventViewController.event, event)
    }

}
