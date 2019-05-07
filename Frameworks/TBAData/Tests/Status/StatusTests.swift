import TBAData
import TBAKit
import XCTest

class StatusTestCase: TBADataTestCase {

    func test_status() {
        XCTAssertNil(Status.status(in: viewContext))
        let status = coreDataTestFixture.insertStatus()
        XCTAssertEqual(status, Status.status(in: viewContext))
    }

    func test_insert() {
        let model = TBAStatus(android: TBAAppInfo(latestAppVersion: 3, minAppVersion: 4),
                              ios: TBAAppInfo(latestAppVersion: 1, minAppVersion: -1),
                              currentSeason: 2015,
                              downEvents: ["2018miket"],
                              datafeedDown: true,
                              maxSeason: 2016)
        let status = Status.insert(model, in: viewContext)

        XCTAssertEqual(status.currentSeason, 2015)
        XCTAssertEqual(status.downEvents!.count, 1)
        XCTAssertEqual(status.maxSeason, 2016)
        XCTAssert(status.isDatafeedDown!.boolValue)
        XCTAssertEqual(status.minAppVersion, -1)
        XCTAssertEqual(status.latestAppVersion, 1)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_update() {
        let statusOne = coreDataTestFixture.insertStatus()
        try! viewContext.save()

        XCTAssertEqual(statusOne.latestAppVersion, -1)

        let statusTwo = Status.fromPlist(bundle: Bundle(for: type(of: self)), in: viewContext)!

        // Sanity check
        XCTAssertEqual(statusOne, statusTwo)
        XCTAssertEqual(statusOne.latestAppVersion, 3)
    }

    func test_fromPlist() {
        let status = Status.fromPlist(bundle: Bundle(for: type(of: self)), in: viewContext)!

        XCTAssertEqual(status.currentSeason, 2015)
        XCTAssertEqual(status.downEvents!.count, 0)
        XCTAssertEqual(status.maxSeason, 2016)
        XCTAssertFalse(status.isDatafeedDown!.boolValue)
        XCTAssertEqual(status.minAppVersion, -1)
        XCTAssertEqual(status.latestAppVersion, 3)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_isOrphaned() {
        let status = coreDataTestFixture.insertStatus()
        XCTAssertFalse(status.isOrphaned)
    }

    func test_safeMinAppVersion_none() {
        let status = Status.init(entity: Status.entity(), insertInto: viewContext)
        XCTAssertEqual(status.safeMinAppVersion, -1)
    }

    func test_safeMinAppVersion() {
        let status = Status.init(entity: Status.entity(), insertInto: viewContext)
        status.minAppVersion = NSNumber(value: 3)

        XCTAssertEqual(status.safeMinAppVersion, 3)
    }

}
