import TBADataTesting
import XCTest
@testable import TBAData
@testable import The_Blue_Alliance

class EventAllianceCellViewModelTestCase: TBADataTestCase {

    func test_init() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.picksRaw = NSOrderedSet(array: [
            Team.insert("frc1", in: persistentContainer.viewContext),
            Team.insert("frc3", in: persistentContainer.viewContext),
            Team.insert("frc2", in: persistentContainer.viewContext),
            Team.insert("frc4", in: persistentContainer.viewContext)
        ])

        let first = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)
        XCTAssertEqual(first.picks, ["frc1", "frc3", "frc2", "frc4"])
        XCTAssertEqual(first.allianceName, "Alliance 2")
        XCTAssertNil(first.allianceLevel)
        XCTAssertFalse(first.hasAllianceLevel)

        alliance.nameRaw = "Alliance 3"
        let second = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)
        XCTAssertEqual(second.picks, ["frc1", "frc3", "frc2", "frc4"])
        XCTAssertEqual(second.allianceName, "Alliance 3")
        XCTAssertNil(first.allianceLevel)
        XCTAssertFalse(first.hasAllianceLevel)

        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        status.levelRaw = "f"
        status.statusRaw = "won"
        alliance.statusRaw = status
        let third = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)
        XCTAssertEqual(third.picks, ["frc1", "frc3", "frc2", "frc4"])
        XCTAssertEqual(third.allianceName, "Alliance 3")
        XCTAssertEqual(third.allianceLevel, "W")
        XCTAssert(third.hasAllianceLevel)
    }

}
