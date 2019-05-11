import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class TeamViewControllerTests: TBAViewControllerSnapshotTestCase {

    var teamViewController: TeamViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        let team = coreDataTestFixture.insertTeam()

        teamViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: coreDataTestFixture.persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: teamViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        teamViewController = nil

        super.tearDown()
    }

    func test_no_mytba() {
        verifyLayer(viewControllerTester.window.layer)
    }

    func test_mytba() {
        myTBA.authToken = "abcd123"
        verifyLayer(viewControllerTester.window.layer)
    }

    // TODO: Add more tests

}
