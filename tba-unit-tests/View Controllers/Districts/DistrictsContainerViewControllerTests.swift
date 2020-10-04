import XCTest
@testable import The_Blue_Alliance

class DistrictsContainerViewControllerTests: TBATestCase {

    var navigationController: MockNavigationController!
    var districtsContainerViewController: DistrictsContainerViewController!

    override func setUp() {
        super.setUp()

        districtsContainerViewController = DistrictsContainerViewController(myTBA: myTBA,
                                                                            statusService: statusService,
                                                                            urlOpener: urlOpener,
                                                                            dependencies: dependencies)
        districtsContainerViewController.viewDidLoad()

        navigationController = MockNavigationController(rootViewController: districtsContainerViewController)
    }

    override func tearDown() {
        navigationController = nil
        districtsContainerViewController = nil

        super.tearDown()
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
        XCTAssert(navigationController.pushedViewController is DistrictViewController)

        let districtViewController = navigationController.pushedViewController as! DistrictViewController
        XCTAssertEqual(districtViewController.district, district)
    }

}
