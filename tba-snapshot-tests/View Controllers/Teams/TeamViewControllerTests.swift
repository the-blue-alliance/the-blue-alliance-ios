import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class TeamViewControllerTests: TBAViewControllerSnapshotTestCase {

    var teamViewController: TeamViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    var team: Team!

    override func setUp() {
        super.setUp()

        team = coreDataTestFixture.insertTeam()

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
        verifyViewController(viewControllerTester)
    }

    func test_mytba() {
        myTBA.authToken = "abcd123"
        verifyViewController(viewControllerTester)
    }

    func test_year() {
        team.yearsParticipated = [2018]

        waitOneSecond()
        tbaKit.sendUnmodifiedStubForAllRequests()

        waitOneSecond()
        verifyViewController(viewControllerTester)
    }

    func test_long_name() {
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"

        waitOneSecond()
        tbaKit.sendUnmodifiedStubForAllRequests()

        waitOneSecond()
        verifyViewController(viewControllerTester)
    }

    func test_avatar() {
        let teamMedia = coreDataTestFixture.insertAvatar()
        team.addToMedia(teamMedia)
        team.yearsParticipated = [2018]

        waitOneSecond()
        tbaKit.sendUnmodifiedStubForAllRequests()

        waitOneSecond()
        verifyViewController(viewControllerTester)
    }

    func test_avatar_long_name() {
        let teamMedia = coreDataTestFixture.insertAvatar()
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"
        team.addToMedia(teamMedia)
        team.yearsParticipated = [2018]

        waitOneSecond()
        tbaKit.sendUnmodifiedStubForAllRequests()

        waitOneSecond()
        verifyViewController(viewControllerTester)
    }

}
