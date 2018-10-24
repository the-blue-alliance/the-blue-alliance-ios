import Foundation
import XCTest
@testable import The_Blue_Alliance

class MatchTestCase: CoreDataTestCase {

    func alliance(allianceKey: String) -> MatchAlliance {
        let alliance = MatchAlliance(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.allianceKey = allianceKey
        alliance.teams = NSOrderedSet(array: ["frc3333", "frc7332", "frc2337"].map({ (key) -> TeamKey in
            let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
            teamKey.key = key
            return teamKey
        }))
        return alliance
    }

    func test_compLevel() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        // No compLevelString
        XCTAssertNil(match.compLevel)

        // Unknown compLevelString
        match.compLevelString = "zz"
        XCTAssertNil(match.compLevel)

        match.compLevelString = "qm"
        XCTAssertEqual(match.compLevel, .qualification)

        match.compLevelString = "ef"
        XCTAssertEqual(match.compLevel, .eightfinal)

        match.compLevelString = "qf"
        XCTAssertEqual(match.compLevel, .quarterfinal)

        match.compLevelString = "sf"
        XCTAssertEqual(match.compLevel, .semifinal)

        match.compLevelString = "f"
        XCTAssertEqual(match.compLevel, .final)
    }

    func test_compLevel_sortOrder() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        match.compLevelString = "qm"
        XCTAssertEqual(match.compLevel?.sortOrder, 0)

        match.compLevelString = "ef"
        XCTAssertEqual(match.compLevel?.sortOrder, 1)

        match.compLevelString = "qf"
        XCTAssertEqual(match.compLevel?.sortOrder, 2)

        match.compLevelString = "sf"
        XCTAssertEqual(match.compLevel?.sortOrder, 3)

        match.compLevelString = "f"
        XCTAssertEqual(match.compLevel?.sortOrder, 4)
    }

    func test_compLevel_level() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        match.compLevelString = "qm"
        XCTAssertEqual(match.compLevel?.level, "Qualification")

        match.compLevelString = "ef"
        XCTAssertEqual(match.compLevel?.level, "Octofinal")

        match.compLevelString = "qf"
        XCTAssertEqual(match.compLevel?.level, "Quarterfinal")

        match.compLevelString = "sf"
        XCTAssertEqual(match.compLevel?.level, "Semifinal")

        match.compLevelString = "f"
        XCTAssertEqual(match.compLevel?.level, "Finals")
    }

    func test_compLevel_levelShort() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        match.compLevelString = "qm"
        XCTAssertEqual(match.compLevel?.levelShort, "Quals")

        match.compLevelString = "ef"
        XCTAssertEqual(match.compLevel?.levelShort, "Eighths")

        match.compLevelString = "qf"
        XCTAssertEqual(match.compLevel?.levelShort, "Quarters")

        match.compLevelString = "sf"
        XCTAssertEqual(match.compLevel?.levelShort, "Semis")

        match.compLevelString = "f"
        XCTAssertEqual(match.compLevel?.levelShort, "Finals")
    }

    func test_timeString() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let defaultTimeZone = NSTimeZone.default

        NSTimeZone.default = TimeZone(abbreviation: "EST")!
        XCTAssertNil(match.timeString)

        // Set default time zone for this test
        match.time = NSNumber(value: 1425764880)
        XCTAssertEqual(match.timeString, "Sat 4:48 PM")

        addTeardownBlock {
            NSTimeZone.default = defaultTimeZone
        }
    }

    func test_redAlliance() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.redAlliance)

        match.alliances = Set([alliance(allianceKey: "red")]) as NSSet
        XCTAssertNotNil(match.redAlliance)
    }

    func test_redAllianceTeamNumbers() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliances = Set([alliance(allianceKey: "red")]) as NSSet
        XCTAssertEqual(match.redAllianceTeamNumbers, ["2337", "7332", "3333"])
    }

    func test_blueAlliance() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.blueAlliance)

        match.alliances = Set([alliance(allianceKey: "blue")]) as NSSet
        XCTAssertNotNil(match.blueAlliance)
    }

    func test_blueAllianceTeamNumbers() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliances = Set([alliance(allianceKey: "blue")]) as NSSet
        XCTAssertEqual(match.blueAllianceTeamNumbers, ["2337", "7332", "3333"])
    }

    func test_friendlyName() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.setNumber = 2
        match.matchNumber = 73

        // No compLevel - just show the match number
        XCTAssertEqual(match.friendlyName, "Match 73")

        match.compLevelString = MatchCompLevel.qualification.rawValue
        XCTAssertEqual(match.friendlyName, "Quals 73")

        match.compLevelString = MatchCompLevel.eightfinal.rawValue
        XCTAssertEqual(match.friendlyName, "Eighths 2 - 73")
    }

}
