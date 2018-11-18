import XCTest
@testable import The_Blue_Alliance

class EventsContainerViewController_TestCase: TBATestCase {

    var eventsContainerViewController: EventsContainerViewController!
    var navigationController: MockNavigationController!

    override func setUp() {
        super.setUp()

        eventsContainerViewController = EventsContainerViewController(remoteConfig: remoteConfig,
                                                                      urlOpener: urlOpener,
                                                                      userDefaults: userDefaults,
                                                                      persistentContainer: persistentContainer,
                                                                      tbaKit: tbaKit)
        navigationController = MockNavigationController(rootViewController: eventsContainerViewController)

        eventsContainerViewController.viewDidLoad()
    }

    override func tearDown() {
        eventsContainerViewController = nil
        navigationController = nil

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

    func test_showYearSelect() {
        let presentExpectation = XCTestExpectation(description: "present called")
        navigationController.presentCalled = { (vc) in
            XCTAssert(vc is UINavigationController)
            let nav = vc as! UINavigationController
            XCTAssert(nav.viewControllers.first is YearSelectViewController)

            presentExpectation.fulfill()
        }
        eventsContainerViewController.navigationTitleTapped()

        wait(for: [presentExpectation], timeout: 1.0)
    }

    func test_eventWeekSelected() {
        let event = insertTestEvent(year: 2014)
        eventsContainerViewController.weekEventSelected(event)

        XCTAssertEqual(eventsContainerViewController.year, 2014)
        XCTAssertEqual(eventsContainerViewController.eventsViewController.weekEvent, event)
    }

    func test_eventWeeksUpdated() {
        let event = insertTestEvent(year: 2015)
        eventsContainerViewController.eventsViewController.weekEvent = event
        eventsContainerViewController.weekEventUpdated()

        XCTAssertEqual(eventsContainerViewController.navigationTitle, "Week 2 Events")
        XCTAssertEqual(eventsContainerViewController.navigationSubtitle, "▾ 2015")
    }

    func test_pushEvent() {
        let event = insertTestEvent(year: 2015)

        let showDetailViewControllerExpectation = XCTestExpectation(description: "showDetailViewController called")
        navigationController.showDetailViewControllerCalled = { (vc) in
            XCTAssert(vc is UINavigationController)
            let nav = vc as! UINavigationController
            XCTAssert(nav.viewControllers.first is EventViewController)

            showDetailViewControllerExpectation.fulfill()
        }
        eventsContainerViewController.eventSelected(event)

        wait(for: [showDetailViewControllerExpectation], timeout: 1.0)
    }

    func insertTestEvent(year: Int) -> Event {
        // Required: endDate, eventCode, eventType, key, name, startDate, year
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.endDate = Calendar.current.date(from: DateComponents(year: year, month: 3, day: 7))
        event.eventCode = "miket"
        event.eventType = 1
        event.key = "2015miket"
        event.name = "FIM District - Kettering University Event"
        event.endDate = Calendar.current.date(from: DateComponents(year: year, month: 3, day: 5))
        event.week = NSNumber(value: 1)
        event.year = year as NSNumber
        return event
    }

}
