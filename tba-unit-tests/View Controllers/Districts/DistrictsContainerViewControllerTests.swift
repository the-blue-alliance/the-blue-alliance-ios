import XCTest
@testable import TBA

class DistrictsContainerViewControllerTests: TBATestCase {

    var districtsContainerViewController: DistrictsContainerViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        districtsContainerViewController = DistrictsContainerViewController(myTBA: myTBA,
                                                                            statusService: statusService,
                                                                            urlOpener: urlOpener,
                                                                            persistentContainer: persistentContainer,
                                                                            tbaKit: tbaKit,
                                                                            userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: districtsContainerViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        districtsContainerViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer)
    }
    
    func test_delegates() {
        XCTAssertNotNil(districtsContainerViewController.navigationTitleDelegate)
        XCTAssertNotNil(districtsContainerViewController.districtsViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(districtsContainerViewController.title, "Districts")

        XCTAssertEqual(districtsContainerViewController.navigationTitle, "Districts")
        XCTAssertEqual(districtsContainerViewController.navigationSubtitle, "▾ 2015")
    }

    func test_tabBar() {
        XCTAssertEqual(districtsContainerViewController.tabBarItem.title, "Districts")
    }

    func test_showsDistricts() {
        XCTAssert(districtsContainerViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is DistrictsViewController
        }))
    }

    func test_years_showYearSelect() {
        districtsContainerViewController.navigationTitleTapped()

        navigationController.presentCalled = {
            XCTAssert($0 is UINavigationController)
            let nav = $0 as! UINavigationController

            XCTAssert(nav.viewControllers.first is SelectTableViewController<DistrictsContainerViewController>)
            let selectViewController = nav.viewControllers.first as! SelectTableViewController<DistrictsContainerViewController>

            XCTAssertEqual(selectViewController.current, 2015)
            XCTAssertEqual(selectViewController.options, [2009, 2010, 2011, 2012, 2013, 2014, 2015])
        }
    }

    func test_years_selectYear() {
        districtsContainerViewController.optionSelected(2016)
        XCTAssertEqual(districtsContainerViewController.year, 2016)
    }

    func test_years_selectYearTitle() {
        XCTAssertEqual(districtsContainerViewController.titleForOption(2016), "2016")
    }

    func test_districts_pushDistrict() {
        let district = insertDistrict()

        districtsContainerViewController.districtSelected(district)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is DistrictViewController)
        let districtViewController = nav.viewControllers.first as! DistrictViewController
        XCTAssertEqual(districtViewController.district, district)
    }

}
