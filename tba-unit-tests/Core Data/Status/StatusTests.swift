import XCTest
@testable import TBA

class StatusTestCase: CoreDataTestCase {

    func test_status() {
        XCTAssertNil(Status.status(in: persistentContainer.viewContext))
        let status = insertStatus()
        XCTAssertEqual(status, Status.status(in: persistentContainer.viewContext))
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
        XCTAssertEqual(status.downEvents!.count, 1)
        XCTAssertEqual(status.maxSeason, 2016)
        XCTAssert(status.isDatafeedDown!.boolValue)
        XCTAssertEqual(status.minAppVersion, -1)
        XCTAssertEqual(status.latestAppVersion, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let statusOne = insertStatus()
        try! persistentContainer.viewContext.save()

        XCTAssertEqual(statusOne.latestAppVersion, -1)

        let statusTwo = Status.fromPlist(bundle: Bundle(for: type(of: self)), in: persistentContainer.viewContext)!

        // Sanity check
        XCTAssertEqual(statusOne, statusTwo)
        XCTAssertEqual(statusOne.latestAppVersion, 3)
    }

    func test_fromPlist() {
        let status = Status.fromPlist(bundle: Bundle(for: type(of: self)), in: persistentContainer.viewContext)!

        XCTAssertEqual(status.currentSeason, 2015)
        XCTAssertEqual(status.downEvents!.count, 0)
        XCTAssertEqual(status.maxSeason, 2016)
        XCTAssertFalse(status.isDatafeedDown!.boolValue)
        XCTAssertEqual(status.minAppVersion, -1)
        XCTAssertEqual(status.latestAppVersion, 3)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_isOrphaned() {
        let status = insertStatus()
        XCTAssertFalse(status.isOrphaned)
    }

}
