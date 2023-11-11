import CoreData
import TBAKit
import XCTest
@testable import TBAData

open class TBADataTestCase: XCTestCase {

    private static let managedObjectModel: NSManagedObjectModel = {
        let modelBundle = Bundle.module
        return NSManagedObjectModel.mergedModel(from: [modelBundle])!
    } ()
    public var persistentContainer: TBAPersistenceContainer!

    private var saveNotificationCompleteHandler: ((Notification, NSManagedObjectContext)->())?

    override open func setUp() {
        super.setUp()

        persistentContainer = TBAPersistenceContainer(name: "TBA", managedObjectModel: TBADataTestCase.managedObjectModel)

        let description = NSPersistentStoreDescription()
        description.type = NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false
        description.configuration = "Default"
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        persistentContainer.persistentStoreDescriptions = [description]

        let persistentContainerSetupExpectation = XCTestExpectation()
        persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            XCTAssertNotNil(persistentStoreDescription)
            XCTAssertNil(error)

            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

            persistentContainerSetupExpectation.fulfill()
        })
        wait(for: [persistentContainerSetupExpectation], timeout: 10.0)

        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    override open func tearDown() {
        NotificationCenter.default.removeObserver(self)

        super.tearDown()
    }

    public func contextSaved(notification: Notification) {
        saveNotificationCompleteHandler?(notification, notification.object as! NSManagedObjectContext)
    }

    public func waitForSavedNotification(completeHandler: @escaping ((Notification, NSManagedObjectContext)->()) ) {
        saveNotificationCompleteHandler = completeHandler
    }

    public func viewContextSaveExpectation() -> XCTestExpectation {
        let saveExpectation = expectation(description: "View context saved")
        waitForSavedNotification { (notification, context) in
            // Check that we saved the view context
            guard context == self.persistentContainer.viewContext else {
                return
            }
            saveExpectation.fulfill()
        }
        return saveExpectation
    }

    public func backgroundContextSaveExpectation() -> XCTestExpectation {
        let saveExpectation = expectation(description: "Background context saved")
        waitForSavedNotification { (notification, context) in
            // Check that we saved the background context
            guard context.concurrencyType == .privateQueueConcurrencyType else {
                return
            }
            saveExpectation.fulfill()
        }
        return saveExpectation
    }

    public func insertStatus() -> Status {
        let model = TBAStatus(android: TBAAppInfo(latestAppVersion: -1, minAppVersion: -1),
                              ios: TBAAppInfo(latestAppVersion: -1, minAppVersion: -1),
                              currentSeason: 2015,
                              downEvents: [],
                              datafeedDown: false,
                              maxSeason: 2016)
        return Status.insert(model, in: persistentContainer.viewContext)
    }

    public func insertEvent(year: Int = 2015) -> Event {
        let model = TBAEvent(key: "\(year)qcmo",
            name: "FRC Festival de Robotique - Montreal Regional",
            eventCode: "qcmo",
            eventType: 0,
            district: nil,
            city: nil,
            stateProv: nil,
            country: nil,
            startDate: Event.dateFormatter.date(from: "\(year)-03-18")!,
            endDate: Event.dateFormatter.date(from: "\(year)-03-21")!,
            year: year,
            shortName: "Festival de Robotique - Montreal",
            eventTypeString: "Reginal",
            week: 3,
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

        return Event.insert(model, in: persistentContainer.viewContext)
    }

    public func insertDistrictEvent(eventKey: String = "2018miket") -> Event {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let model = TBAEvent(key: eventKey,
                             name: "FIM District Kettering University Event #1",
                             eventCode: "miket",
                             eventType: 1,
                             district: district,
                             city: "Flint",
                             stateProv: "MI",
                             country: "USA",
                             startDate: Event.dateFormatter.date(from: "2018-03-01")!,
                             endDate: Event.dateFormatter.date(from: "2018-03-03")!,
                             year: 2018,
                             shortName: "Kettering University #1",
                             eventTypeString: "District",
                             week: 0,
                             address: "1700 University Ave, Flint, MI 48504, USA",
                             postalCode: "48504",
                             gmapsPlaceID: "ChIJLx7Nx2SCI4gRzW8R94I3pEw",
                             gmapsURL: "https://maps.google.com/?cid=5522600078693461965",
                             lat: 43.0115468,
                             lng: -83.7138531,
                             locationName: "Kettering University",
                             timezone: "America/New_York",
                             website: "http://www.firstinmichigan.org",
                             firstEventID: "27941",
                             firstEventCode: "MIKET",
                             webcasts: nil,
                             divisionKeys: [],
                             parentEventKey: nil,
                             playoffType: nil,
                             playoffTypeString: nil)

        return Event.insert(model, in: persistentContainer.viewContext)
    }

    public func insertTeam() -> Team {
        let team = TBATeam(key: "frc7332",
                           teamNumber: 7332,
                           nickname: "The Rawrbotz",
                           name: "General Motors/Premier Tooling Systems/Microsoft/The Chrysler Foundation/Davison Tool & Engineering, L.L.C./The Robot Space/Michigan Department of Education/Kettering University/Taylor Steel/DXC Technology/Complete Scrap/ZF North America & Grand Blanc Community High School",
                           city: "Anytown",
                           stateProv: "MI",
                           country: "USA",
                           address: nil,
                           postalCode: nil,
                           gmapsPlaceID: nil,
                           gmapsURL: nil,
                           lat: nil,
                           lng: nil,
                           locationName: nil,
                           website: nil,
                           rookieYear: 2010,
                           homeChampionship: nil)
        return Team.insert(team, in: persistentContainer.viewContext)
    }

    public func insertMatch(eventKey: String = "2018ctsc") -> Match {
        let match = TBAMatch(key: "\(eventKey)_qm1",
            compLevel: "qm",
            setNumber: 1,
            matchNumber: 1,
            alliances: [
                "red": TBAMatchAlliance(score: 396, teams: ["frc1", "frc2", "frc3"]),
                "blue": TBAMatchAlliance(score: 256, teams: ["frc4", "frc5", "frc6"]),
            ],
            winningAlliance: "red",
            eventKey: eventKey,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: nil,
            videos: [TBAMatchVideo(key: "KXELQZI46FA", type: "youtube")])
        return Match.insert(match, in: persistentContainer.viewContext)
    }

    public func insertDistrict() -> District {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        return District.insert(district, in: persistentContainer.viewContext)
    }

    public func insertEventRaking() -> EventRanking {
        let event = insertEvent()

        let model = TBAEventRanking(teamKey: "frc1", rank: 2, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25.0, 3], sortOrders: [2.08, 530.0, 3])
        let ranking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key, in: persistentContainer.viewContext)
        ranking.eventRaw = event
        return ranking
    }

}
