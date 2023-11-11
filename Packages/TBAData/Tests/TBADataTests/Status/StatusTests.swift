import CoreData
import TBAKit
import XCTest
@testable import TBAData

class StatusTestCase: TBADataTestCase {

    func test_currentSeason() {
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        status.currentSeasonRaw = NSNumber(value: 2020)
        XCTAssertEqual(status.currentSeason, 2020)
    }

    func test_isDatafeedDown() {
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        status.isDatafeedDownRaw = NSNumber(value: true)
        XCTAssert(status.isDatafeedDown)
    }

    func test_latestAppVersion() {
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        status.latestAppVersionRaw = NSNumber(value: -1)
        XCTAssertEqual(status.latestAppVersion, -1)
    }

    func test_maxSeason() {
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        status.maxSeasonRaw = NSNumber(value: 2020)
        XCTAssertEqual(status.maxSeason, 2020)
    }

    func test_minAppVersion() {
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        status.minAppVersionRaw = NSNumber(value: -1)
        XCTAssertEqual(status.minAppVersion, -1)
    }

    func test_downEvents() {
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(status.downEvents, [])
        let event = insertEvent()
        status.downEventsRaw = NSSet(array: [event])
        XCTAssertEqual(status.downEvents, [event])
    }

    func test_status() {
        XCTAssertNil(Status.status(in: persistentContainer.viewContext))
        let status = insertStatus()
        XCTAssertEqual(status, Status.status(in: persistentContainer.viewContext))
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<Status> = Status.fetchRequest()
        XCTAssertEqual(fr.entityName, Status.entityName)
    }

    func test_insert() {
        let model = TBAStatus(android: TBAAppInfo(latestAppVersion: 3, minAppVersion: 4),
                              ios: TBAAppInfo(latestAppVersion: 1, minAppVersion: -1),
                              currentSeason: 2015,
                              downEvents: ["2018miket"],
                              datafeedDown: true,
                              maxSeason: 2016)
        let status = Status.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(status.currentSeason, 2015)
        XCTAssertEqual(status.downEvents.count, 1)
        XCTAssertEqual(status.maxSeason, 2016)
        XCTAssert(status.isDatafeedDown)
        XCTAssertEqual(status.minAppVersion, -1)
        XCTAssertEqual(status.latestAppVersion, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let statusOne = insertStatus()
        try! persistentContainer.viewContext.save()

        XCTAssertEqual(statusOne.latestAppVersion, -1)

        let statusTwo = Status.fromPlist(bundle: Bundle.module, in: persistentContainer.viewContext)!

        // Sanity check
        XCTAssertEqual(statusOne, statusTwo)
        XCTAssertEqual(statusOne.latestAppVersion, 3)
    }

    func test_fromPlist() {
        let status = Status.fromPlist(bundle: Bundle.module, in: persistentContainer.viewContext)!

        XCTAssertEqual(status.currentSeason, 2015)
        XCTAssertEqual(status.downEvents.count, 0)
        XCTAssertEqual(status.maxSeason, 2016)
        XCTAssertFalse(status.isDatafeedDown)
        XCTAssertEqual(status.minAppVersion, -1)
        XCTAssertEqual(status.latestAppVersion, 3)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

}
