import XCTest
@testable import TBA

class DistrictViewControllerTests: TBATestCase {

    var district: District {
        return districtViewController.district
    }

    var districtViewController: DistrictViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        let district = insertDistrict()

        districtViewController = DistrictViewController(district: district,
                                                        myTBA: myTBA,
                                                        statusService: statusService,
                                                        urlOpener: urlOpener,
                                                        persistentContainer: persistentContainer,
                                                        tbaKit: tbaKit,
                                                        userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: districtViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        districtViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer)
    }

    private func insertDistrictEvents(district: District) {
        let eventOne = TBAEvent(key: "2018miket",
                                name: "FIM District Kettering University Event #1",
                                eventCode: "miket",
                                eventType: 1,
                                district: nil,
                                city: nil,
                                stateProv: nil,
                                country: nil,
                                startDate: Event.dateFormatter.date(from: "2018-03-01")!,
                                endDate: Event.dateFormatter.date(from: "2018-03-03")!,
                                year: 2018,
                                shortName: "Kettering University #1",
                                eventTypeString: "District",
                                week: 0,
                                address: nil,
                                postalCode: nil,
                                gmapsPlaceID: nil,
                                gmapsURL: nil,
                                lat: nil,
                                lng: nil,
                                locationName: nil,
                                timezone: nil,
                                website: nil,
                                firstEventID: nil,
                                firstEventCode: nil,
                                webcasts: nil,
                                divisionKeys: [],
                                parentEventKey: nil,
                                playoffType: nil,
                                playoffTypeString: nil)

        let eventTwo = TBAEvent(key: "2018mike2",
                                name: "FIM District Kettering University Event #2",
                                eventCode: "mike2",
                                eventType: 1,
                                district: nil,
                                city: nil,
                                stateProv: nil,
                                country: nil,
                                startDate: Event.dateFormatter.date(from: "2018-03-08")!,
                                endDate: Event.dateFormatter.date(from: "2018-03-10")!,
                                year: 2018,
                                shortName: "Kettering University #2",
                                eventTypeString: "District",
                                week: 0,
                                address: nil,
                                postalCode: nil,
                                gmapsPlaceID: nil,
                                gmapsURL: nil,
                                lat: nil,
                                lng: nil,
                                locationName: nil,
                                timezone: nil,
                                website: nil,
                                firstEventID: nil,
                                firstEventCode: nil,
                                webcasts: nil,
                                divisionKeys: [],
                                parentEventKey: nil,
                                playoffType: nil,
                                playoffTypeString: nil)

        district.insert([eventOne, eventTwo])
    }

    private func insertDistrictTeams(district: District) {
        let teamOne = TBATeam(key: "frc1", teamNumber: 1, name: "Team 1", rookieYear: 2001)
        let teamTwo = TBATeam(key: "frc2", teamNumber: 2, name: "Team 2", rookieYear: 2002)

        district.insert([teamOne, teamTwo])
    }

    private func insertDistrictRankings(district: District) {
        let rankingOne = TBADistrictRanking(teamKey: "frc7332", rank: 1, pointTotal: 209, eventPoints: [])
        let rankingTwo = TBADistrictRanking(teamKey: "frc1", rank: 2, pointTotal: 32, eventPoints: [])

        district.insert([rankingOne, rankingTwo])
    }

    func test_delegates() {
        XCTAssertNotNil(districtViewController.eventsViewController.delegate)
        XCTAssertNotNil(districtViewController.teamsViewController.delegate)
        XCTAssertNotNil(districtViewController.rankingsViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(districtViewController.title, "2018 FIRST In Michigan Districts")
    }

    func test_showsEvents() {
        XCTAssert(districtViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is DistrictEventsViewController
        }))
    }

    func test_showsTeams() {
        XCTAssert(districtViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is DistrictTeamsViewController
        }))
    }

    func test_showsRankings() {
        XCTAssert(districtViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is DistrictRankingsViewController
        }))
    }

    func test_evets_pushesEvent() {
        insertDistrictEvents(district: district)

        let event = district.events!.anyObject() as! Event
        districtViewController.eventSelected(event)

        XCTAssert(navigationController.pushedViewController is EventViewController)
        let eventViewController = navigationController.pushedViewController as! EventViewController
        XCTAssertEqual(eventViewController.event, event)
    }

    func test_evets_pushesTeam() {
        insertDistrictTeams(district: district)

        let team = district.teams!.anyObject() as! Team
        districtViewController.teamSelected(team)

        XCTAssert(navigationController.pushedViewController is TeamViewController)
        let teamViewController = navigationController.pushedViewController as! TeamViewController
        XCTAssertEqual(teamViewController.team, team)
    }

    func test_events_eventWeekTitle() {
        insertDistrictEvents(district: district)

        let event = (district.events!.allObjects as! [Event]).first(where: { $0.week == 0 })!
        XCTAssertEqual(districtViewController.title(for: event), "Week 1 Events")
    }

    func test_rankings_pushesRanking() {
        insertDistrictRankings(district: district)

        let ranking = district.rankings!.anyObject() as! DistrictRanking
        districtViewController.districtRankingSelected(ranking)

        XCTAssert(navigationController.pushedViewController is TeamAtDistrictViewController)
        let teamAtDistrictViewController = navigationController.pushedViewController as! TeamAtDistrictViewController
        XCTAssertEqual(teamAtDistrictViewController.ranking, ranking)
    }

}
