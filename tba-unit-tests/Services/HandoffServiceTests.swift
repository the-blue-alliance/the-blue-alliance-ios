import CoreData
import CoreSpotlight
import Photos
import MyTBAKit
import Search
import TBAKit
import UIKit
import XCTest
@testable import TBAData
@testable import The_Blue_Alliance

struct FakeRootController: RootController {

    let fcmTokenProvider: FCMTokenProvider
    let myTBA: MyTBA
    let pasteboard: UIPasteboard? = nil
    let photoLibrary: PHPhotoLibrary? = nil
    let pushService: PushService
    let searchService: SearchService
    let statusService: StatusService
    let urlOpener: URLOpener
    let dependencies: Dependencies

    var continueSearchExpectation: XCTestExpectation?
    var continueSearchResult: Bool = true

    var showEventExpectation: XCTestExpectation?
    var showEventResult: Bool = true

    var showTeamExpectation: XCTestExpectation?
    var showTeamResult: Bool = true

    func continueSearch(_ searchText: String) -> Bool {
        continueSearchExpectation?.fulfill()
        return continueSearchResult
    }

    func show(event: Event) -> Bool {
        showEventExpectation?.fulfill()
        return showEventResult
    }

    func show(team: Team) -> Bool {
        showTeamExpectation?.fulfill()
        return showTeamResult
    }

}

class HandoffServiceTests: TBATestCase {

    private var handoffService: HandoffService!
    private var tabBarController = UITabBarController()

    override func setUp() {
        super.setUp()

        let rootController = FakeRootController(fcmTokenProvider: fcmTokenProvider, myTBA: myTBA, pushService: pushService, searchService: searchService, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.handoffService = HandoffService(errorRecorder: errorRecorder, persistentContainer: persistentContainer, rootControllerProvider: { return rootController })
    }

    func test_handoff_unsupported() {
        let activity = NSUserActivity(activityType: "test")
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_web_noURL() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_web_noPath() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com")
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_web_noKey() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/events")
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_web_invalidType() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/events/fim")
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_web_event_new() {
        let eventKey = "2020miket"
        // Make sure Event doesn't exist before
        XCTAssertNil(Event.findOrFetch(in: persistentContainer.viewContext, matching: Event.predicate(key: eventKey)))

        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/event/\(eventKey)")
        XCTAssertTrue(handoffService.application(continue: activity))

        // Make sure Event was inserted
        let event = Event.findOrFetch(in: persistentContainer.viewContext, matching: Event.predicate(key: eventKey))!
        XCTAssertEqual(event.key, eventKey)

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertEqual(handoffService.continueURI, event.objectID.uriRepresentation())
    }

    func test_handoff_web_event_existing() {
        let eventKey = "2020miket"
        let eventName = "Test Event"
        let event = Event.findOrCreate(in: persistentContainer.viewContext, matching: Event.predicate(key: eventKey)) {
            $0.keyRaw = eventKey
            $0.nameRaw = eventName
        }

        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/event/\(eventKey)")
        XCTAssertTrue(handoffService.application(continue: activity))

        // Make sure Event was inserted
        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(event.key, eventKey)
        XCTAssertEqual(event.name, eventName)

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertEqual(handoffService.continueURI, event.objectID.uriRepresentation())
    }

    func test_handoff_web_event_invalid() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/event/frc7332")
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_web_team_new() {
        let teamKey = "frc7332"
        // Make sure Team doesn't exist before
        XCTAssertNil(Team.findOrFetch(in: persistentContainer.viewContext, matching: Team.predicate(key: teamKey)))

        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/team/\(teamKey)")
        XCTAssertTrue(handoffService.application(continue: activity))

        // Make sure Team was inserted
        let team = Team.findOrFetch(in: persistentContainer.viewContext, matching: Team.predicate(key: teamKey))!
        XCTAssertEqual(team.key, teamKey)

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)

        XCTAssertEqual(handoffService.continueURI, team.objectID.uriRepresentation())
    }

    func test_handoff_web_team_existing() {
        let teamKey = "frc7332"
        let teamName = "The Rawrbotz"
        let team = Team.findOrCreate(in: persistentContainer.viewContext, matching: Team.predicate(key: teamKey)) {
            $0.keyRaw = teamKey
            $0.nameRaw = teamName
        }

        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/team/\(teamKey)")
        XCTAssertTrue(handoffService.application(continue: activity))

        // Make sure Team was inserted
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 1)
        XCTAssertEqual(team.key, teamKey)
        XCTAssertEqual(team.name, teamName)

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)

        XCTAssertEqual(handoffService.continueURI, team.objectID.uriRepresentation())
    }

    func test_handoff_web_team_invalid() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.thebluealliance.com/team/2020miket")
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_client_noURL() {
        let activity = NSUserActivity(activityType: TBAActivityTypeEvent)
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_handoff_client_event_new() {
        let eventKey = "2020miket"
        let url = URL(string: "https://www.thebluealliance.com/event/\(eventKey)")!

        let activity = NSUserActivity(activityType: TBAActivityTypeEvent)
        activity.userInfo = [TBAActivityURL: url]
        XCTAssertTrue(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 1)
        let event = events.first!
        XCTAssertEqual(event.key, eventKey)

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertEqual(handoffService.continueURI, event.objectID.uriRepresentation())
    }

    func test_handoff_client_event_existing() {
        let eventKey = "2020miket"
        let url = URL(string: "https://www.thebluealliance.com/event/\(eventKey)")!

        let eventName = "Test Event"
        let event = Event.findOrCreate(in: persistentContainer.viewContext, matching: Event.predicate(key: eventKey)) {
            $0.keyRaw = eventKey
            $0.nameRaw = eventName
        }

        let activity = NSUserActivity(activityType: TBAActivityTypeEvent)
        activity.userInfo = [TBAActivityURL: url]
        XCTAssertTrue(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(event.key, eventKey)
        XCTAssertEqual(event.name, eventName)

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertEqual(handoffService.continueURI, event.objectID.uriRepresentation())
    }

    func test_handoff_client_team_new() {
        let teamKey = "frc7332"
        let url = URL(string: "https://www.thebluealliance.com/team/\(teamKey)")!

        let activity = NSUserActivity(activityType: TBAActivityTypeTeam)
        activity.userInfo = [TBAActivityURL: url]
        XCTAssertTrue(handoffService.application(continue: activity))

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 1)
        let team = teams.first!
        XCTAssertEqual(team.key, teamKey)

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)

        XCTAssertEqual(handoffService.continueURI, team.objectID.uriRepresentation())
    }

    func test_handoff_client_team_existing() {
        let teamKey = "frc7332"
        let url = URL(string: "https://www.thebluealliance.com/team/\(teamKey)")!

        let teamName = "The Rawrbotz"
        let team = Team.findOrCreate(in: persistentContainer.viewContext, matching: Team.predicate(key: teamKey)) {
            $0.keyRaw = teamKey
            $0.nameRaw = teamName
        }

        let activity = NSUserActivity(activityType: TBAActivityTypeTeam)
        activity.userInfo = [TBAActivityURL: url]
        XCTAssertTrue(handoffService.application(continue: activity))

        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 1)
        XCTAssertEqual(team.key, teamKey)
        XCTAssertEqual(team.name, teamName)

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)

        XCTAssertEqual(handoffService.continueURI, team.objectID.uriRepresentation())
    }

    func test_search_action_noIdentifier() {
        let activity = NSUserActivity(activityType: CSSearchableItemActionType)
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_search_action_invalidURL() {
        let activity = NSUserActivity(activityType: CSSearchableItemActionType)
        activity.userInfo = [CSSearchableItemActivityIdentifier: ""]
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueURI)
    }

    func test_search_action() {
        let urlString = "x-coredata:///Team/t8EFA7EFD-DE1E-495F-9868-60DBBE340A722"

        let activity = NSUserActivity(activityType: CSSearchableItemActionType)
        activity.userInfo = [CSSearchableItemActivityIdentifier: urlString]
        XCTAssertTrue(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertEqual(handoffService.continueURI, URL(string: urlString))
    }

    func test_search_query_noQuery() {
        let activity = NSUserActivity(activityType: CSQueryContinuationActionType)
        XCTAssertFalse(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertNil(handoffService.continueSearchText)
    }

    func test_search_query() {
        let searchText = "Kette"

        let activity = NSUserActivity(activityType: CSQueryContinuationActionType)
        activity.userInfo = [CSSearchQueryString: searchText]
        XCTAssertTrue(handoffService.application(continue: activity))

        let events = Event.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(events.count, 0)
        let teams = Team.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(teams.count, 0)

        XCTAssertEqual(handoffService.continueSearchText, searchText)
    }

}
