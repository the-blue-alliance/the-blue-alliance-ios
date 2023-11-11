import CoreData
import TBAKit
import XCTest
@testable import TBAData

class MatchTestCase: TBADataTestCase {

    func test_actualTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.actualTime)
        match.actualTimeRaw = NSNumber(value: 1520090781)
        XCTAssertEqual(match.actualTime, 1520090781)
    }

    func test_breakdown() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.breakdownRaw)
        match.breakdownRaw = [:]
        XCTAssertNotNil(match.breakdown)
    }

    func test_compLevelSortOrder() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.compLevelSortOrder)
        match.compLevelSortOrderRaw = NSNumber(value: 1)
        XCTAssertEqual(match.compLevelSortOrder, 1)
    }

    func test_compLevelString() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.compLevelStringRaw = "qm"
        XCTAssertEqual(match.compLevelString, "qm")
    }

    func test_compLevel() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        // Unknown compLevelString
        match.compLevelStringRaw = "zz"
        XCTAssertNil(match.compLevel)

        match.compLevelStringRaw = "qm"
        XCTAssertEqual(match.compLevel, .qualification)

        match.compLevelStringRaw = "ef"
        XCTAssertEqual(match.compLevel, .eightfinal)

        match.compLevelStringRaw = "qf"
        XCTAssertEqual(match.compLevel, .quarterfinal)

        match.compLevelStringRaw = "sf"
        XCTAssertEqual(match.compLevel, .semifinal)

        match.compLevelStringRaw = "f"
        XCTAssertEqual(match.compLevel, .final)
    }

    func test_key() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.keyRaw = "2018miket_qm1"
        XCTAssertEqual(match.key, "2018miket_qm1")
    }

    func test_matchNumber() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.matchNumberRaw = NSNumber(value: 2)
        XCTAssertEqual(match.matchNumber, 2)
    }

    func test_postResultTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.postResultTime)
        match.postResultTimeRaw = NSNumber(value: 1520090781)
        XCTAssertEqual(match.postResultTime, 1520090781)
    }

    func test_predictedTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.predictedTime)
        match.predictedTimeRaw = NSNumber(value: 1520090781)
        XCTAssertEqual(match.predictedTime, 1520090781)
    }

    func test_setNumber() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.setNumberRaw = NSNumber(value: 2)
        XCTAssertEqual(match.setNumber, 2)
    }

    func test_time() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.time)
        match.timeRaw = NSNumber(value: 1520090781)
        XCTAssertEqual(match.time, 1520090781)
    }

    func test_winningAlliance() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.winningAlliance)
        match.winningAllianceRaw = "red"
        XCTAssertEqual(match.winningAlliance, "red")
    }

    func test_alliances() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(match.alliances, [])

        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = NSSet(array: [alliance])
        XCTAssertEqual(match.alliances, [alliance])
    }

    func test_event() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        match.eventRaw = event
        XCTAssertEqual(match.event, event)
    }

    func test_videos() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(match.videos, [])

        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)
        match.videosRaw = NSSet(array: [video])
        XCTAssertEqual(match.videos, [video])
    }

    func test_zebra() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.zebra)

        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        match.zebraRaw = zebra
        XCTAssertEqual(match.zebra, zebra)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<Match> = Match.fetchRequest()
        XCTAssertEqual(fr.entityName, Match.entityName)
    }

    func test_predicate() {
        let predicate = Match.predicate(key: "2018miket_qm1")
        XCTAssertEqual(predicate.predicateFormat, "keyRaw == \"2018miket_qm1\"")
    }

    func test_compLevelSortOrderKeyPath() {
        let kp = Match.compLevelSortOrderKeyPath()
        XCTAssertEqual(kp, #keyPath(Match.compLevelSortOrderRaw))
    }

    func test_sortDescriptors() {
        let sds = Match.sortDescriptors(ascending: true)
        XCTAssertEqual(sds.count, 3)
        XCTAssert(sds.reduce(true, { $0 && $1.ascending }))

        XCTAssert(sds.contains(where: { $0.key == #keyPath(Match.compLevelSortOrderRaw) }))
        XCTAssert(sds.contains(where: { $0.key == #keyPath(Match.setNumberRaw) }))
        XCTAssert(sds.contains(where: { $0.key == #keyPath(Match.matchNumberRaw) }))

        let sdsFalse = Match.sortDescriptors(ascending: false)
        XCTAssertFalse(sdsFalse.reduce(false, { $0 || $1.ascending }))
    }

    func test_eventPredicate() {
        let event = insertEvent()
        let predicate = Match.eventPredicate(eventKey: event.key)
        XCTAssertEqual(predicate.predicateFormat, "eventRaw.keyRaw == \"2015qcmo\"")

        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.eventRaw = event
        _ = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let results = Match.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [match])
    }

    func test_eventTeamPredicate() {
        let event = insertEvent()
        let team = insertTeam()
        let predicate = Match.eventTeamPredicate(eventKey: event.key, teamKey: team.key)
        XCTAssertEqual(predicate.predicateFormat, "eventRaw.keyRaw == \"2015qcmo\" AND SUBQUERY(alliancesRaw, $a, ANY $a.teamsRaw.keyRaw IN {\"frc7332\"}).@count > 0")

        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.eventRaw = event
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.teamsRaw = NSOrderedSet(array: [team])
        match.alliancesRaw = NSSet(array: [alliance])

        _ = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let results = Match.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [match])
    }

    func test_teamKeysPredicate() {
        let team = insertTeam()
        let predicate = Match.teamKeysPredicate(teamKeys: [team.key])
        XCTAssertEqual(predicate.predicateFormat, "SUBQUERY(alliancesRaw, $a, ANY $a.teamsRaw.keyRaw IN {\"frc7332\"}).@count > 0")

        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.teamsRaw = NSOrderedSet(array: [team])
        match.alliancesRaw = NSSet(array: [alliance])

        _ = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let results = Match.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [match])
    }

    func alliance(allianceKey: String, dqs: [String]? = nil) -> MatchAlliance {
        let alliance = MatchAlliance(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.allianceKeyRaw = allianceKey
        alliance.teamsRaw = NSOrderedSet(array: ["frc2337", "frc7332", "frc3333"].map {
            return Team.insert($0, in: persistentContainer.viewContext)
        })
        if let dqs = dqs {
            alliance.dqTeamsRaw = NSOrderedSet(array: dqs.map {
                return Team.insert($0, in: persistentContainer.viewContext)
            })
        }
        return alliance
    }

    func test_insert() {
        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let model = TBAMatch(key: "2018miket_sf2m3",
                             compLevel: "sf",
                             setNumber: 2,
                             matchNumber: 3,
                             alliances: ["red": redAlliance, "blue": blueAlliance],
                             winningAlliance: "blue",
                             eventKey: "2018miket",
                             time: 1520109780,
                             actualTime: 1520090745,
                             predictedTime: 1520109779,
                             postResultTime: 1520090929,
                             breakdown: ["red": [:], "blue": [:]],
                             videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let match = Match.insert(model, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(match.key, "2018miket_sf2m3")
        XCTAssertEqual(match.compLevelString, "sf")
        XCTAssertEqual(match.setNumber, 2)
        XCTAssertEqual(match.matchNumber, 3)
        XCTAssertEqual(match.alliances.count, 2)
        XCTAssertEqual(match.winningAlliance, "blue")
        XCTAssertEqual(match.time, 1520109780)
        XCTAssertEqual(match.actualTime, 1520090745)
        XCTAssertEqual(match.predictedTime, 1520109779)
        XCTAssertEqual(match.postResultTime, 1520090929)
        XCTAssertEqual(match.videos.count, 1)

        // Ensure Match can have an Event
        let event = insertDistrictEvent()
        match.eventRaw = event

        XCTAssertEqual(match.event, event)
        XCTAssert(event.matches.contains(match))
    }

    func test_update() {
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAllianceModel = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let orangeAllianceModel = TBAMatchAlliance(score: 100, teams: ["frc1111"])
        let modelOne = TBAMatch(key: "2018miket_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel, "blue": blueAllianceModel, "orange": orangeAllianceModel],
            winningAlliance: "blue",
            eventKey: "2018miket",
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let matchOne = Match.insert(modelOne, in: persistentContainer.viewContext)
        let blueAlliance = (matchOne.alliances).first(where: { $0.allianceKey == "blue" })!
        let orangeAlliance = (matchOne.alliances).first(where: { $0.allianceKey == "orange" })!
        let redAllianceOne = (matchOne.alliances).first(where: { $0.allianceKey == "red" })!
        let video = matchOne.videos.first!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let redAllianceModelTwo = TBAMatchAlliance(score: 200, teams: ["frc7777"])

        let modelTwo = TBAMatch(key: "2018miket_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModelTwo, "blue": blueAllianceModel],
            winningAlliance: "red",
            eventKey: "2018miket",
            time: 1520109781,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [])

        let matchTwo = Match.insert(modelTwo, in: persistentContainer.viewContext)
        let redAllianceTwo = (matchTwo.alliances).first(where: { $0.allianceKey == "red" })!

        // Sanity check
        XCTAssertEqual(matchOne, matchTwo)
        XCTAssertEqual(redAllianceOne, redAllianceTwo)

        // Check that our values have been updated
        XCTAssertEqual(matchOne.alliances.count, 2)
        XCTAssertEqual(matchOne.winningAlliance, "red")
        XCTAssertEqual(matchOne.time, 1520109781)
        XCTAssertEqual(matchOne.videos.count, 0)

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
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc1"])
        let videoOneModel = TBAMatchVideo(key: "key_one", type: "youtube")
        let videoTwoModel = TBAMatchVideo(key: "key_two", type: "youtube")
        let modelOne = TBAMatch(key: "2018miket_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: "2018miket",
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoOneModel, videoTwoModel])
        let matchOne = Match.insert(modelOne, in: persistentContainer.viewContext)

        let videoOne = (matchOne.videos).first(where: { $0.key == "key_one" })!
        let videoTwo = (matchOne.videos).first(where: { $0.key == "key_two" })!

        let modelTwo = TBAMatch(key: "2018miket_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: "2018miket",
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoTwoModel])
        let matchTwo = Match.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(matchOne, matchTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that we've managed dropping Match Video relationships properly
        XCTAssertFalse(matchOne.videos.contains(videoOne))
        XCTAssert(matchOne.videos.contains(videoTwo))

        // Video One should be deleted since it's an orphan
        XCTAssertNil(videoOne.managedObjectContext)

        // Video Two should not be deleted since it's attached to a Match
        XCTAssertNotNil(videoTwo.managedObjectContext)
    }

    func test_insert_zebra() {
        let match = insertMatch()
        XCTAssertNil(match.zebra)

        let modelZebra = TBAMatchZebra(key: match.key, times: [0.0, 0.1], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc7332", xs: [nil, 0.1], ys: [0.2, nil])
            ]
        ])
        match.insert(modelZebra)
        XCTAssertNotNil(match.zebra)

        let oldZebra = try! XCTUnwrap(match.zebra)
        XCTAssertNotNil(oldZebra.managedObjectContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let newModelZebra = TBAMatchZebra(key: "\(match.key)_1", times: [0.0, 0.1], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
            ]
        ])
        match.insert(newModelZebra)
        XCTAssertNotNil(match.zebra)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNil(oldZebra.managedObjectContext)
    }

    func test_delete() {
        // Test cascades
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAllianceModel = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let model = TBAMatch(key: "2018miket_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel, "blue": blueAllianceModel],
            winningAlliance: "blue",
            eventKey: "2018miket",
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let match = Match.insert(model, in: persistentContainer.viewContext)

        let modelZebra = TBAMatchZebra(key: match.key, times: [0.0, 0.1], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc7332", xs: [nil, 0.1], ys: [0.2, nil])
            ]
        ])
        match.insert(modelZebra)
        XCTAssertNotNil(match.zebra)
        let zebra = try! XCTUnwrap(match.zebra)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let blueAlliance = (match.alliances).first(where: { $0.allianceKey == "blue" })!
        let redAlliance = (match.alliances).first(where: { $0.allianceKey == "red" })!
        let video = match.videos.first!

        persistentContainer.viewContext.delete(match)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Sanity check
        XCTAssertNil(match.managedObjectContext)

        // Test that both of our alliances have been deleted
        XCTAssertNil(blueAlliance.managedObjectContext)
        XCTAssertNil(redAlliance.managedObjectContext)

        // Test that our video has been deleted
        XCTAssertNil(video.managedObjectContext)

        // Test that our zebra data has been deleted
        XCTAssertNil(zebra.managedObjectContext)
    }

    func test_delete_videoHasMatch() {
        let redAllianceModel = TBAMatchAlliance(score: 200, teams: ["frc1"])
        let videoOneModel = TBAMatchVideo(key: "key_one", type: "youtube")
        let videoTwoModel = TBAMatchVideo(key: "key_two", type: "youtube")
        let modelOne = TBAMatch(key: "2018miket_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: "2018miket",
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoOneModel, videoTwoModel])
        let matchOne = Match.insert(modelOne, in: persistentContainer.viewContext)

        let videoOne = (matchOne.videos).first(where: { $0.key == "key_one" })!
        let videoTwo = (matchOne.videos).first(where: { $0.key == "key_two" })!

        let modelTwo = TBAMatch(key: "2018miket_f1m1",
            compLevel: "f",
            setNumber: 1,
            matchNumber: 1,
            alliances: ["red": redAllianceModel],
            winningAlliance: "red",
            eventKey: "2018miket",
            time: nil,
            actualTime: nil,
            predictedTime: nil,
            postResultTime: nil,
            breakdown: nil,
            videos: [videoTwoModel])
        let matchTwo = Match.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertNotEqual(matchOne, matchTwo)

        persistentContainer.viewContext.delete(matchOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that we've managed dropping Match Video relationships properly
        XCTAssert(matchTwo.videos.contains(videoTwo))
        XCTAssertEqual(videoTwo.matches.count, 1)

        // Video One should be deleted since it's an orphan
        XCTAssertNil(videoOne.managedObjectContext)

        // Video Two should not be deleted since it's attached to a Match
        XCTAssertNotNil(videoTwo.managedObjectContext)
    }

    func test_isOrphaned() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.keyRaw = "2018miket_qm1"
        XCTAssert(match.isOrphaned)

        // Is not orphaned if attached to an Event
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToMatchesRaw(match)
        XCTAssertFalse(match.isOrphaned)

        event.removeFromMatchesRaw(match)
        XCTAssert(match.isOrphaned)

        // Is not orphaned if attached to a myTBA object
        let favorite = Favorite.init(entity: Favorite.entity(), insertInto: persistentContainer.viewContext)
        favorite.modelKeyRaw = match.key
        XCTAssertFalse(match.isOrphaned)
    }

    func test_compLevel_sortOrder() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        match.compLevelStringRaw = "qm"
        XCTAssertEqual(match.compLevel?.sortOrder, 0)

        match.compLevelStringRaw = "ef"
        XCTAssertEqual(match.compLevel?.sortOrder, 1)

        match.compLevelStringRaw = "qf"
        XCTAssertEqual(match.compLevel?.sortOrder, 2)

        match.compLevelStringRaw = "sf"
        XCTAssertEqual(match.compLevel?.sortOrder, 3)

        match.compLevelStringRaw = "f"
        XCTAssertEqual(match.compLevel?.sortOrder, 4)
    }

    func test_compLevel_level() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        match.compLevelStringRaw = "qm"
        XCTAssertEqual(match.compLevel?.level, "Qualification")

        match.compLevelStringRaw = "ef"
        XCTAssertEqual(match.compLevel?.level, "Octofinals")

        match.compLevelStringRaw = "qf"
        XCTAssertEqual(match.compLevel?.level, "Quarterfinals")

        match.compLevelStringRaw = "sf"
        XCTAssertEqual(match.compLevel?.level, "Semifinals")

        match.compLevelStringRaw = "f"
        XCTAssertEqual(match.compLevel?.level, "Finals")
    }

    func test_compLevel_levelShort() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        match.compLevelStringRaw = "qm"
        XCTAssertEqual(match.compLevel?.levelShort, "Quals")

        match.compLevelStringRaw = "ef"
        XCTAssertEqual(match.compLevel?.levelShort, "Eighths")

        match.compLevelStringRaw = "qf"
        XCTAssertEqual(match.compLevel?.levelShort, "Quarters")

        match.compLevelStringRaw = "sf"
        XCTAssertEqual(match.compLevel?.levelShort, "Semis")

        match.compLevelStringRaw = "f"
        XCTAssertEqual(match.compLevel?.levelShort, "Finals")
    }

    func test_startTime_actualTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.actualTimeRaw = NSNumber(value: 1520090781)
        match.predictedTimeRaw = NSNumber(value: 1520090780)
        match.timeRaw = NSNumber(value: 1520090779)

        XCTAssertNotNil(match.startTime)
        XCTAssertEqual(match.startTime, match.actualTime)
    }

    func test_startTime_predictedTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.predictedTimeRaw = NSNumber(value: 1520090780)
        match.timeRaw = NSNumber(value: 1520090779)

        XCTAssertNotNil(match.startTime)
        XCTAssertEqual(match.startTime, match.predictedTime)
    }

    func test_startTime_time() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.timeRaw = NSNumber(value: 1520090779)

        XCTAssertNotNil(match.startTime)
        XCTAssertEqual(match.startTime, match.time)
    }

    func test_startTimeString_actualTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let defaultTimeZone = NSTimeZone.default

        NSTimeZone.default = TimeZone(abbreviation: "EST")!
        XCTAssertNil(match.startTimeString)

        // Set default time zone for this test
        match.actualTimeRaw = NSNumber(value: 1520010781)
        match.predictedTimeRaw = NSNumber(value: 1520020780)
        match.timeRaw = NSNumber(value: 1520090779)
        XCTAssertEqual(match.startTimeString, "Fri 12:13 PM")

        addTeardownBlock {
            NSTimeZone.default = defaultTimeZone
        }
    }

    func test_startTimeString_predictedTime() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let defaultTimeZone = NSTimeZone.default

        NSTimeZone.default = TimeZone(abbreviation: "EST")!
        XCTAssertNil(match.startTimeString)

        // Set default time zone for this test
        match.predictedTimeRaw = NSNumber(value: 1520020780)
        match.timeRaw = NSNumber(value: 1520090779)
        XCTAssertEqual(match.startTimeString, "Fri 2:59 PM")

        addTeardownBlock {
            NSTimeZone.default = defaultTimeZone
        }
    }

    func test_startTimeString_time() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)

        let defaultTimeZone = NSTimeZone.default

        NSTimeZone.default = TimeZone(abbreviation: "EST")!
        XCTAssertNil(match.startTimeString)

        // Set default time zone for this test
        match.timeRaw = NSNumber(value: 1520090779)
        XCTAssertEqual(match.startTimeString, "Sat 10:26 AM")

        addTeardownBlock {
            NSTimeZone.default = defaultTimeZone
        }
    }

    func test_redAlliance() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.redAlliance)

        match.alliancesRaw = Set([alliance(allianceKey: "red")]) as NSSet
        XCTAssertNotNil(match.redAlliance)
    }

    func test_redAllianceTeamKeys() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = Set([alliance(allianceKey: "red")]) as NSSet
        XCTAssertEqual(match.redAllianceTeamKeys, ["frc2337", "frc7332", "frc3333"])
    }

    func test_redAllianceTeamNumbers() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = Set([alliance(allianceKey: "red")]) as NSSet
        XCTAssertEqual(match.redAllianceTeamNumbers, ["2337", "7332", "3333"])
    }

    func test_blueAlliance() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(match.blueAlliance)

        match.alliancesRaw = Set([alliance(allianceKey: "blue")]) as NSSet
        XCTAssertNotNil(match.blueAlliance)
    }

    func test_blueAllianceTeamKeys() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = Set([alliance(allianceKey: "blue")]) as NSSet
        XCTAssertEqual(match.blueAllianceTeamKeys, ["frc2337", "frc7332", "frc3333"])
    }

    func test_blueAllianceTeamNumbers() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = Set([alliance(allianceKey: "blue")]) as NSSet
        XCTAssertEqual(match.blueAllianceTeamNumbers, ["2337", "7332", "3333"])
    }

    func test_teamKeys() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = Set([alliance(allianceKey: "blue"), alliance(allianceKey: "red")]) as NSSet
        XCTAssertEqual(match.teams.map({ $0.key }), ["frc2337", "frc7332", "frc3333", "frc2337", "frc7332", "frc3333"])
    }

    func test_dqTeamKeys() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.alliancesRaw = Set([alliance(allianceKey: "blue", dqs: ["frc7332"])]) as NSSet
        XCTAssertEqual(match.dqTeamKeys, ["frc7332"])
    }

    func test_friendlyName() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.setNumberRaw = 2
        match.matchNumberRaw = 73

        // No compLevel - just show the match number
        match.compLevelStringRaw = "zz"
        XCTAssertEqual(match.friendlyName, "Match 73")

        match.compLevelStringRaw = MatchCompLevel.qualification.rawValue
        XCTAssertEqual(match.friendlyName, "Quals 73")

        match.compLevelStringRaw = MatchCompLevel.eightfinal.rawValue
        XCTAssertEqual(match.friendlyName, "Eighths 2-73")
    }

    func test_myTBASubscribable() {
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.keyRaw = "2018miket_qm1"

        XCTAssertEqual(match.modelKey, "2018miket_qm1")
        XCTAssertEqual(match.modelType, .match)
        XCTAssertEqual(Match.notificationTypes.count, 3)
    }

    func test_year_event() {
        let event = insertDistrictEvent()
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.eventRaw = event
        XCTAssertEqual(match.event.year, 2018)
    }

    func test_find() {
        let key = "2018ctsc_qm1"

        XCTAssertNil(Match.forKey(key, in: persistentContainer.viewContext))
        _ = insertMatch()
        XCTAssertNotNil(Match.forKey(key, in: persistentContainer.viewContext))
    }

}
