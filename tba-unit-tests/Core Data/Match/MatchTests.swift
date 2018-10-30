import TBAKit
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

    func test_insert() {
        let event = districtEvent()
        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let model = TBAMatch(key: "\(event.key!)_sf2m3",
                             compLevel: "sf",
                             setNumber: 2,
                             matchNumber: 3,
                             alliances: ["red": redAlliance, "blue": blueAlliance],
                             winningAlliance: "blue",
                             eventKey: event.key!,
                             time: 1520109780,
                             actualTime: 1520090745,
                             predictedTime: 1520109780,
                             postResultTime: 1520090929,
                             breakdown: ["red": [:], "blue": [:]],
                             videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let match = Match.insert(model, event: event, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(match.key, "2018miket_sf2m3")
        XCTAssertEqual(match.compLevelString, "sf")
        XCTAssertEqual(match.setNumber, 2)
        XCTAssertEqual(match.matchNumber, 3)
        XCTAssertEqual(match.alliances?.count, 2)
        XCTAssertEqual(match.winningAlliance, "blue")
        XCTAssertEqual(match.event, event)
        XCTAssertEqual(match.time, 1520109780)
        XCTAssertEqual(match.actualTime, 1520090745)
        XCTAssertEqual(match.predictedTime, 1520109780)
        XCTAssertEqual(match.postResultTime, 1520090929)
        XCTAssertEqual(match.videos?.count, 1)
    }

    func test_update() {
        let event = districtEvent()
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAllianceModel = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let orangeAllianceModel = TBAMatchAlliance(score: 100, teams: ["frc1111"])
        let modelOne = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel, "blue": blueAllianceModel, "orange": orangeAllianceModel],
            winningAlliance: "blue",
            eventKey: event.key!,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let matchOne = Match.insert(modelOne, event: event, in: persistentContainer.viewContext)
        let blueAlliance = (matchOne.alliances!.allObjects as! [MatchAlliance]).first(where: { $0.allianceKey == "blue" })!
        let orangeAlliance = (matchOne.alliances!.allObjects as! [MatchAlliance]).first(where: { $0.allianceKey == "orange" })!
        let redAllianceOne = (matchOne.alliances!.allObjects as! [MatchAlliance]).first(where: { $0.allianceKey == "red" })!
        let video = matchOne.videos!.allObjects.first as! MatchVideo

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let redAllianceModelTwo = TBAMatchAlliance(score: 200, teams: ["frc7777"])

        let modelTwo = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModelTwo, "blue": blueAllianceModel],
            winningAlliance: "red",
            eventKey: event.key!,
            time: 1520109781,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [])

        let matchTwo = Match.insert(modelTwo, event: event, in: persistentContainer.viewContext)
        let redAllianceTwo = (matchTwo.alliances!.allObjects as! [MatchAlliance]).first(where: { $0.allianceKey == "red" })!

        // Sanity check
        XCTAssertEqual(matchOne, matchTwo)
        XCTAssertEqual(redAllianceOne, redAllianceTwo)

        // Check that our values have been updated
        XCTAssertEqual(matchOne.alliances?.count, 2)
        XCTAssertEqual(matchOne.winningAlliance, "red")
        XCTAssertEqual(matchOne.time, 1520109781)
        XCTAssertEqual(matchOne.videos?.count, 0)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Blue Alliance/Red Alliance should not be deleted, since it still refers to a Match
        XCTAssertNotNil(blueAlliance.managedObjectContext)
        XCTAssertNotNil(redAllianceOne.managedObjectContext)

        // Orange Alliance should be deleted, since it no longer refers to a match
        XCTAssertNil(orangeAlliance.managedObjectContext)

        // Match Video should be deleted, since it's now an orphan
        XCTAssertNil(video.managedObjectContext)
    }

    func test_update_orphans() {
        let event = districtEvent()
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc1"])
        let videoOneModel = TBAMatchVideo(key: "key_one", type: "youtube")
        let videoTwoModel = TBAMatchVideo(key: "key_two", type: "youtube")
        let modelOne = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: event.key!,
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoOneModel, videoTwoModel])
        let matchOne = Match.insert(modelOne, event: event, in: persistentContainer.viewContext)

        let videoOne = (matchOne.videos!.allObjects as! [MatchVideo]).first(where: { $0.key == "key_one" })!
        let videoTwo = (matchOne.videos!.allObjects as! [MatchVideo]).first(where: { $0.key == "key_two" })!

        let modelTwo = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: event.key!,
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoTwoModel])
        let matchTwo = Match.insert(modelTwo, event: event, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(matchOne, matchTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that we've managed dropping Match Video relationships properly
        XCTAssertFalse(matchOne.videos!.contains(videoOne))
        XCTAssert(matchOne.videos!.contains(videoTwo))

        // Video One should be deleted since it's an orphan
        XCTAssertNil(videoOne.managedObjectContext)

        // Video Two should not be deleted since it's attached to a Match
        XCTAssertNotNil(videoTwo.managedObjectContext)
    }

    func test_delete() {
        // Test cascades
        let event = districtEvent()
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAllianceModel = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let model = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel, "blue": blueAllianceModel],
            winningAlliance: "blue",
            eventKey: event.key!,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let match = Match.insert(model, event: event, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let blueAlliance = (match.alliances!.allObjects as! [MatchAlliance]).first(where: { $0.allianceKey == "blue" })!
        let redAlliance = (match.alliances!.allObjects as! [MatchAlliance]).first(where: { $0.allianceKey == "red" })!
        let video = match.videos!.allObjects.first as! MatchVideo

        persistentContainer.viewContext.delete(match)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Sanity check
        XCTAssertNil(match.managedObjectContext)

        // Test that both of our alliances have been deleted
        XCTAssertNil(blueAlliance.managedObjectContext)
        XCTAssertNil(redAlliance.managedObjectContext)

        // Test that our video has been deleted
        XCTAssertNil(video.managedObjectContext)
    }

    func test_delete_videoHasMatch() {
        let event = districtEvent()
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc1"])
        let videoOneModel = TBAMatchVideo(key: "key_one", type: "youtube")
        let videoTwoModel = TBAMatchVideo(key: "key_two", type: "youtube")
        let modelOne = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: event.key!,
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoOneModel, videoTwoModel])
        let matchOne = Match.insert(modelOne, event: event, in: persistentContainer.viewContext)

        let videoOne = (matchOne.videos!.allObjects as! [MatchVideo]).first(where: { $0.key == "key_one" })!
        let videoTwo = (matchOne.videos!.allObjects as! [MatchVideo]).first(where: { $0.key == "key_two" })!

        let modelTwo = TBAMatch(key: "\(event.key!)_f1m1",
            compLevel: "f",
            setNumber: 1,
            matchNumber: 1,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: event.key!,
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoTwoModel])
        let matchTwo = Match.insert(modelTwo, event: event, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertNotEqual(matchOne, matchTwo)

        persistentContainer.viewContext.delete(matchOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that we've managed dropping Match Video relationships properly
        XCTAssert(matchTwo.videos!.contains(videoTwo))
        XCTAssertEqual(videoTwo.matches?.count, 1)

        // Video One should be deleted since it's an orphan
        XCTAssertNil(videoOne.managedObjectContext)

        // Video Two should not be deleted since it's attached to a Match
        XCTAssertNotNil(videoTwo.managedObjectContext)
    }

    func test_isOrphaned() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(match.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToMatches(match)
        XCTAssertFalse(match.isOrphaned)

        event.removeFromMatches(match)
        XCTAssert(match.isOrphaned)
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
