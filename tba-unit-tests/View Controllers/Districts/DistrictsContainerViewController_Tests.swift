import XCTest
@testable import The_Blue_Alliance

class DistrictsContainerViewController_TestCase: TBATestCase {

    var districtsContainerViewController: DistrictsContainerViewController!
    var navigationController: MockNavigationController!

    override func setUp() {
        super.setUp()

        districtsContainerViewController = DistrictsContainerViewController(remoteConfig: remoteConfig,
                                                                            urlOpener: urlOpener,
                                                                            userDefaults: userDefaults,
                                                                            persistentContainer: persistentContainer,
                                                                            tbaKit: tbaKit)
        navigationController = MockNavigationController(rootViewController: districtsContainerViewController)

        districtsContainerViewController.viewDidLoad()
    }

    override func tearDown() {
        districtsContainerViewController = nil
        navigationController = nil

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

    func test_showsTeams() {
        XCTAssert(districtsContainerViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is DistrictsViewController
        }))
    }

    func test_showYearSelect() {
        let presentExpectation = XCTestExpectation(description: "present called")
        navigationController.presentCalled = { (vc) in
            XCTAssert(vc is UINavigationController)
            let nav = vc as! UINavigationController
            XCTAssert(nav.viewControllers.first is SelectTableViewController<DistrictsContainerViewController>)

            presentExpectation.fulfill()
        }
        districtsContainerViewController.navigationTitleTapped()

        wait(for: [presentExpectation], timeout: 1.0)
    }

    func test_selectYear() {
        districtsContainerViewController.optionSelected(2016)
        XCTAssertEqual(districtsContainerViewController.year, 2016)
    }

    func test_selectYearTitle() {
        XCTAssertEqual(districtsContainerViewController.titleForOption(2016), "2016")
    }

    func test_pushDistrict() {
        let district = insertTestDistrict()

        let showDetailViewControllerExpectation = XCTestExpectation(description: "showDetailViewController called")
        navigationController.showDetailViewControllerCalled = { (vc) in
            XCTAssert(vc is UINavigationController)
            let nav = vc as! UINavigationController
            XCTAssert(nav.viewControllers.first is DistrictViewController)

            showDetailViewControllerExpectation.fulfill()
        }
        districtsContainerViewController.districtSelected(district)

        wait(for: [showDetailViewControllerExpectation], timeout: 1.0)
    }

    func insertTestDistrict() -> District {
        // Required: abbreviation, name, key, year
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = "fim"
        district.name = "FIRST In Michigan"
        district.key = "2018fim"
        district.year = 2015
        return district
    }

}
