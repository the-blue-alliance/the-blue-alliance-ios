import XCTest
@testable import TBA

class EventAllianceCellViewModelTestCase: CoreDataTestCase {

    func test_init() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.addToPicks(NSOrderedSet(array: [
            TeamKey.insert(withKey: "frc1", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc3", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc2", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc4", in: persistentContainer.viewContext)
        ]))

        let first = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)
        XCTAssertEqual(first.picks, ["frc1", "frc3", "frc2", "frc4"])
        XCTAssertEqual(first.allianceName, "Alliance 2")
        XCTAssertNil(first.allianceLevel)
        XCTAssertFalse(first.hasAllianceLevel)

        alliance.name = "Alliance 3"
        let second = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)
        XCTAssertEqual(second.picks, ["frc1", "frc3", "frc2", "frc4"])
        XCTAssertEqual(second.allianceName, "Alliance 3")
        XCTAssertNil(first.allianceLevel)
        XCTAssertFalse(first.hasAllianceLevel)

        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        status.level = "f"
        status.status = "won"
        alliance.status = status
        let third = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)
        XCTAssertEqual(third.picks, ["frc1", "frc3", "frc2", "frc4"])
        XCTAssertEqual(third.allianceName, "Alliance 3")
        XCTAssertEqual(third.allianceLevel, "W")
        XCTAssert(third.hasAllianceLevel)
    }

}
