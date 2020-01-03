import TBADataTesting
import TBAKit
import XCTest
@testable import TBAData

class EventTestCase: TBADataTestCase {

    let calendar: Calendar = Calendar.current

    func test_address() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.address)
        event.addressRaw = "address"
        XCTAssertEqual(event.address, "address")
    }

    func test_city() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.city)
        event.cityRaw = "city"
        XCTAssertEqual(event.city, "city")
    }

    func test_country() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.country)
        event.countryRaw = "country"
        XCTAssertEqual(event.country, "country")
    }

    func test_endDate() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.endDate)
        let date = Date()
        event.endDateRaw = date
        XCTAssertEqual(event.endDate, date)
    }

    func test_eventCode() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.eventCode)
        event.eventCodeRaw = "eventCode"
        XCTAssertEqual(event.eventCode, "eventCode")
    }

    func test_eventType() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.eventType)
        event.eventTypeRaw = NSNumber(value: 19292)
        XCTAssertNil(event.eventType)
        event.eventTypeRaw = NSNumber(value: 1)
        XCTAssertEqual(event.eventType, .district)
    }

    func test_eventTypeString() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.eventTypeString)
        event.eventTypeStringRaw = "eventTypeString"
        XCTAssertEqual(event.eventTypeString, "eventTypeString")
    }

    func test_firstEventCode() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.firstEventCode)
        event.firstEventCodeRaw = "firstEventCode"
        XCTAssertEqual(event.firstEventCode, "firstEventCode")
    }

    func test_firstEventID() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.firstEventID)
        event.firstEventIDRaw = "firstEventID"
        XCTAssertEqual(event.firstEventID, "firstEventID")
    }

    func test_gmapsPlaceID() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.gmapsPlaceID)
        event.gmapsPlaceIDRaw = "gmapsPlaceID"
        XCTAssertEqual(event.gmapsPlaceID, "gmapsPlaceID")
    }

    func test_gmapsURL() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.gmapsURL)
        event.gmapsURLRaw = "gmapsURL"
        XCTAssertEqual(event.gmapsURL, "gmapsURL")
    }

    func test_key() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.keyRaw = "key"
        XCTAssertEqual(event.key, "key")
    }

    func test_lat() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.lat)
        event.latRaw = NSNumber(value: 20.02)
        XCTAssertEqual(event.lat, 20.02)
    }

    func test_lng() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.lng)
        event.lngRaw = NSNumber(value: 20.02)
        XCTAssertEqual(event.lng, 20.02)
    }

    func test_locationName() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.locationName)
        event.locationNameRaw = "locationName"
        XCTAssertEqual(event.locationName, "locationName")
    }

    func test_name() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.name)
        event.nameRaw = "name"
        XCTAssertEqual(event.name, "name")
    }

    func test_playoffType() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.playoffType)
        event.playoffTypeRaw = NSNumber(value: 1)
        XCTAssertEqual(event.playoffType, 1)
    }

    func test_playoffTypeString() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.playoffTypeString)
        event.playoffTypeStringRaw = "playoffTypeString"
        XCTAssertEqual(event.playoffTypeString, "playoffTypeString")
    }

    func test_postalCode() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.postalCode)
        event.postalCodeRaw = "postalCode"
        XCTAssertEqual(event.postalCode, "postalCode")
    }

    func test_shortName() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.shortName)
        event.shortNameRaw = "shortName"
        XCTAssertEqual(event.shortName, "shortName")
    }

    func test_startDate() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.startDate)
        let date = Date()
        event.startDateRaw = date
        XCTAssertEqual(event.startDate, date)
    }

    func test_stateProv() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.stateProv)
        event.stateProvRaw = "stateProv"
        XCTAssertEqual(event.stateProv, "stateProv")
    }

    func test_timezone() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.timezone)
        event.timezoneRaw = "timezone"
        XCTAssertEqual(event.timezone, "timezone")
    }

    func test_website() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.website)
        event.websiteRaw = "website"
        XCTAssertEqual(event.website, "website")
    }

    func test_week() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.week)
        event.weekRaw = NSNumber(value: 1)
        XCTAssertEqual(event.week, 1)
    }

    func test_year() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.yearRaw = NSNumber(value: 2020)
        XCTAssertEqual(event.year, 2020)
    }

    func test_insert_year() {
        let modelEventOne = TBAEvent(key: "2018miket", name: "name", eventCode: "code", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])
        let modelEventTwo = TBAEvent(key: "2018mike2", name: "name", eventCode: "code", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])

        Event.insert([modelEventOne, modelEventTwo], year: 2018, in: persistentContainer.viewContext)
        let eventsFirst = Event.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(Event.yearRaw), 2018)
        }

        let eventOne = eventsFirst.first(where: { $0.key == "2018miket" })!
        let eventTwo = eventsFirst.first(where: { $0.key == "2018mike2" })!

        // Sanity check
        XCTAssertNotEqual(eventOne, eventTwo)

        Event.insert([modelEventTwo], year: 2018, in: persistentContainer.viewContext)
        let eventsSecond = Event.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(Event.yearRaw), 2018)
        }

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(eventsSecond, [eventTwo])

        // EventOne should be deleted
        XCTAssertNil(eventOne.managedObjectContext)

        // EventTwo should not be deleted
        XCTAssertNotNil(eventTwo.managedObjectContext)
    }

    func test_insert() {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let eventModel = TBAEvent(key: "2018miket",
                                  name: "Name",
                                  eventCode: "miket",
                                  eventType: 1,
                                  district: district,
                                  city: "city",
                                  stateProv: "state",
                                  country: "country",
                                  startDate: Event.dateFormatter.date(from: "2018-03-01")!,
                                  endDate: Event.dateFormatter.date(from: "2018-03-03")!,
                                  year: 2018,
                                  shortName: "short name",
                                  eventTypeString: "District",
                                  week: 2,
                                  address: "address",
                                  postalCode: "20202",
                                  gmapsPlaceID: "id",
                                  gmapsURL: "url",
                                  lat: 2.22,
                                  lng: 3.33,
                                  locationName: "Location",
                                  timezone: "EST",
                                  website: "website",
                                  firstEventID: "123",
                                  firstEventCode: "something",
                                  webcasts: [TBAWebcast(type: "twitch", channel: "channel")],
                                  divisionKeys: [],
                                  parentEventKey: "2019micmp",
                                  playoffType: 1,
                                  playoffTypeString: "playoff string")

        let event = Event.insert(eventModel, in: persistentContainer.viewContext)

        XCTAssertEqual(event.key, "2018miket")
        XCTAssertEqual(event.name, "Name")
        XCTAssertEqual(event.eventCode, "miket")
        XCTAssertEqual(event.eventType, .district)
        XCTAssertNotNil(event.district)
        XCTAssertEqual(event.city, "city")
        XCTAssertEqual(event.stateProv, "state")
        XCTAssertEqual(event.country, "country")
        XCTAssertNotNil(event.startDate)
        XCTAssertNotNil(event.endDate)
        XCTAssertEqual(event.year, 2018)
        XCTAssertEqual(event.shortName, "short name")
        XCTAssertEqual(event.eventTypeString, "District")
        XCTAssertEqual(event.week, 2)
        XCTAssertEqual(event.address, "address")
        XCTAssertEqual(event.postalCode, "20202")
        XCTAssertEqual(event.gmapsPlaceID, "id")
        XCTAssertEqual(event.gmapsURL, "url")
        XCTAssertEqual(event.lat, 2.22)
        XCTAssertEqual(event.lng, 3.33)
        XCTAssertEqual(event.locationName, "Location")
        XCTAssertEqual(event.timezone, "EST")
        XCTAssertEqual(event.website, "website")
        XCTAssertEqual(event.firstEventID, "123")
        XCTAssertEqual(event.firstEventCode, "something")
        XCTAssertEqual(event.webcasts.count, 1)
        XCTAssertEqual(event.divisions.count, 0)
        XCTAssertEqual(event.parentEvent?.key, "2019micmp")
        XCTAssertEqual(event.playoffType, 1)
        XCTAssertEqual(event.playoffTypeString, "playoff string")

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_divisions() {
        let divisionKeys = ["2019micmp1", "2019micmp2", "2019micmp3", "2019micmp4"]
        let dcmpModel = TBAEvent(key: "2019micmp",
                                 name: "Michigan State Championship",
                                 eventCode: "micmp",
                                 eventType: EventType.districtChampionship.rawValue,
                                 startDate: Event.dateFormatter.date(from: "2018-03-01")!,
                                 endDate: Event.dateFormatter.date(from: "2018-03-03")!,
                                 year: 2019,
                                 eventTypeString: "District Championship",
                                 divisionKeys: divisionKeys)

        let dcmp = Event.insert(dcmpModel, in: persistentContainer.viewContext)

        XCTAssertEqual(dcmp.key, "2019micmp")
        XCTAssertEqual(Set(dcmp.divisions.map({ $0.key })), Set(divisionKeys))

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let divisionModel = TBAEvent(key: "2019micmp1",
                                     name: "Michigan State Championship - DTE Energy Foundation Division",
                                     eventCode: "micmp1",
                                     eventType: EventType.districtChampionshipDivision.rawValue,
                                     startDate: Event.dateFormatter.date(from: "2018-03-01")!,
                                     endDate: Event.dateFormatter.date(from: "2018-03-03")!,
                                     year: 2019,
                                     eventTypeString: "District Championship Division",
                                     divisionKeys: [],
                                     parentEventKey: "2019micmp")

        let division = Event.insert(divisionModel, in: persistentContainer.viewContext)

        XCTAssertEqual(division, dcmp.divisions.first(where: { $0.key == division.key }))
        XCTAssertEqual(dcmp, division.parentEvent)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

    }

    func test_insert_alliances() {
        let event = insertDistrictEvent()

        let modelAllianceOne = TBAAlliance(name: "Alliance 1", picks: ["frc1"])
        let modelAllianceTwo = TBAAlliance(name: "Alliance 2", picks: ["frc2"])

        event.insert([modelAllianceOne, modelAllianceTwo])

        let alliances = event.alliances.array as! [EventAlliance]
        let allianceOne = alliances.first(where: { $0.name == "Alliance 1" })!
        let allianceTwo = alliances.first(where: { $0.name == "Alliance 2" })!

        // Sanity check
        XCTAssertEqual(event.alliances.count, 2)
        XCTAssertNotEqual(allianceOne, allianceTwo)

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc1
        event.insert([modelAllianceTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let alliancesSet = NSSet(array: event.alliances.array)

        // Ensure our Event has managed it's Alliance relationships properly
        XCTAssert(alliancesSet.onlyObject(allianceTwo))

        // First alliance should be deleted
        XCTAssertNil(allianceOne.managedObjectContext)
        // Second alliance should not be deleted
        XCTAssertNotNil(allianceTwo.managedObjectContext)
    }

    func test_insert_awards() {
        // Orphaned Awards and their relationships should be cleaned up
        // We're going to assume this tests `insert` and `prepareForDeletion`
        let event = insertDistrictEvent()

        // Insert Two Awards - one with two Award Recipients, one with one Award Recipient
        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let frc2Model = TBAAwardRecipient(teamKey: "frc2")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key,
                                     recipients: [frc1Model, frc2Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key,
                                     recipients: [frc2Model],
                                     year: 2018)

        event.insert([modelAwardOne, modelAwardTwo])

        let awards = event.awards
        let awardOne = awards.first(where: { $0.awardType == 2 })!
        let awardTwo = awards.first(where: { $0.awardType == 3 })!
        let frc1 = awardOne.recipients.first(where: { $0.team?.key == "frc1" })!
        let frc2 = awardOne.recipients.first(where: { $0.team?.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.awards.count, 2)
        XCTAssertNotEqual(awardOne, awardTwo)

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc1
        event.insert([modelAwardTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event has managed it's Award relationships properly
        XCTAssert(event.awards.onlyObject(awardTwo))

        // First award should be deleted
        XCTAssertNil(awardOne.managedObjectContext)
        // Second award should not be deleted
        XCTAssertNotNil(awardTwo.managedObjectContext)

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssert(awardTwo.recipients.onlyObject(frc2))

        // frc7332 recipient should be deleted
        XCTAssertNil(frc1.managedObjectContext)
        // frc3333 recipient should not be deleted
        XCTAssertNotNil(frc2.managedObjectContext)
    }

    func test_insert_awards_teamKey() {
        let event = insertDistrictEvent()

        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let frc2Model = TBAAwardRecipient(teamKey: "frc2")

        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key,
                                     recipients: [frc1Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key,
                                     recipients: [frc1Model],
                                     year: 2018)
        let modelAwardThree = TBAAward(name: "The Fake Award Three",
                                       awardType: 4,
                                       eventKey: event.key,
                                       recipients: [frc2Model],
                                       year: 2018)

        event.insert([modelAwardOne, modelAwardTwo, modelAwardThree])

        let awards = event.awards
        let awardOne = awards.first(where: { $0.awardType == 2 })!
        let awardTwo = awards.first(where: { $0.awardType == 3 })!
        let awardThree = awards.first(where: { $0.awardType == 4 })!

        let frc1Team = Team.findOrFetch(in: persistentContainer.viewContext, matching: NSPredicate(format: "%K == %@", #keyPath(Team.keyRaw), frc1Model.teamKey!))!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let awardsFirst = Award.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "SUBQUERY(%K, $r, $r.%K.%K == %@).@count == 1",
                                       #keyPath(Award.recipientsRaw), #keyPath(AwardRecipient.teamRaw), #keyPath(Team.keyRaw), frc1Team.key)
        }

        // Sanity check
        XCTAssertNotEqual(awardOne, awardTwo)
        XCTAssertNotEqual(awardOne, awardThree)
        XCTAssertNotEqual(awardTwo, awardThree)

        XCTAssertEqual(event.awards.count, 3)
        XCTAssertEqual(awardsFirst.count, 2)

        event.insert([modelAwardOne], teamKey: frc1Team.key)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let awardsSecond = Award.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "SUBQUERY(%K, $r, $r.%K.%K == %@).@count == 1",
                                       #keyPath(Award.recipientsRaw), #keyPath(AwardRecipient.teamRaw), #keyPath(Team.keyRaw), frc1Team.key)
        }

        XCTAssertEqual(event.awards.count, 2)
        XCTAssertEqual(awardsSecond.count, 1)

        // First and Third Award should not be deleted
        XCTAssertNotNil(awardOne.managedObjectContext)
        XCTAssertNotNil(awardThree.managedObjectContext)

        // Second Award should be deleted
        XCTAssertNil(awardTwo.managedObjectContext)
    }

    func test_insert_insights() {
        let event = insertDistrictEvent()

        let modelInsights = TBAEventInsights(qual: ["abc": 1], playoff: ["def": 2])
        event.insert(modelInsights)

        XCTAssertNotNil(event.insights)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_match() {
        let event = insertDistrictEvent()

        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let model = TBAMatch(key: "\(event.key)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAlliance, "blue": blueAlliance],
            winningAlliance: "blue",
            eventKey: event.key,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        event.insert([model])

        let matches = event.matches
        let match = matches.first(where: { $0.key == "2018miket_sf2m3" })!

        // Sanity check
        XCTAssertEqual(event.matches.count, 1)
        XCTAssertEqual(match.event, event)
    }

    func test_insert_matches() {
        let event = insertDistrictEvent()

        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let modelOne = TBAMatch(key: "\(event.key)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAlliance, "blue": blueAlliance],
            winningAlliance: "blue",
            eventKey: event.key,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let modelTwo = TBAMatch(key: "\(event.key)_f1m1",
            compLevel: "f",
            setNumber: 1,
            matchNumber: 1,
            alliances: ["red": redAlliance, "blue": blueAlliance],
            winningAlliance: "blue",
            eventKey: event.key,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        event.insert([modelOne, modelTwo])

        let matches = event.matches
        let matchOne = matches.first(where: { $0.key == "2018miket_sf2m3" })!
        let matchTwo = matches.first(where: { $0.key == "2018miket_f1m1" })!

        // Sanity check
        XCTAssertEqual(event.matches.count, 2)
        XCTAssertNotEqual(matchOne, matchTwo)

        event.insert([modelTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.matches.onlyObject(matchTwo))

        // MatchOne should be deleted
        XCTAssertNil(matchOne.managedObjectContext)

        // MatchTwo should not be deleted
        XCTAssertNotNil(matchTwo.managedObjectContext)
    }

    func test_insert_rankings() {
        let event = insertDistrictEvent()

        let modelRankingOne = TBAEventRanking(teamKey: "frc1", rank: 1)
        let modelRankingTwo = TBAEventRanking(teamKey: "frc2", rank: 2)

        event.insert([modelRankingOne, modelRankingTwo], sortOrderInfo: nil, extraStatsInfo: nil)

        let rankings = event.rankings
        let rankingOne = rankings.first(where: { $0.team.key == "frc1" })!
        let rankingTwo = rankings.first(where: { $0.team.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.rankings.count, 2)
        XCTAssertNotEqual(rankingOne, rankingTwo)

        event.insert([modelRankingTwo], sortOrderInfo: nil, extraStatsInfo: nil)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.rankings.onlyObject(rankingTwo))

        // RankingOne should be deleted
        XCTAssertNil(rankingOne.managedObjectContext)

        // RankingTwo should not be deleted
        XCTAssertNotNil(rankingTwo.managedObjectContext)
    }

    func test_insert_stats() {
        let event = insertDistrictEvent()

        let modelStatsOne = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.4)
        let modelStatsTwo = TBAStat(teamKey: "frc2", ccwm: 2.2, dpr: 3.3, opr: 4.4)

        event.insert([modelStatsOne, modelStatsTwo])

        let stats = event.stats
        let statsOne = stats.first(where: { $0.team.key == "frc1" })!
        let statsTwo = stats.first(where: { $0.team.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.stats.count, 2)
        XCTAssertNotEqual(statsOne, statsTwo)

        event.insert([modelStatsTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.stats.onlyObject(statsTwo))

        // StatsOne should be deleted
        XCTAssertNil(statsOne.managedObjectContext)

        // StatsTwo should not be deleted
        XCTAssertNotNil(statsTwo.managedObjectContext)
    }

    func test_insert_status() {
        let event = insertDistrictEvent()

        let modelEventStatusOne = TBAEventStatus(teamKey: "frc1", eventKey: event.key, qual: TBAEventStatusQual(numTeams: nil, status: nil, ranking: TBAEventRanking(teamKey: "frc1", rank: 3), sortOrder: nil), alliance: nil, playoff: nil, allianceStatusString: nil, playoffStatusString: nil, overallStatusString: nil, nextMatchKey: nil, lastMatchKey: nil)
        let modelEventStatusTwo = TBAEventStatus(teamKey: "frc2", eventKey: event.key)

        event.insert(modelEventStatusOne)
        event.insert(modelEventStatusTwo)

        let statuses = event.statuses
        let eventStatusOne = statuses.first(where: { $0.team.key == "frc1" })!
        let eventStatusTwo = statuses.first(where: { $0.team.key == "frc2" })!

        // Ensure we setup a relationship to the ranking and the event properly
        XCTAssertEqual(eventStatusOne.qual?.ranking?.event, event)

        // Sanity check
        XCTAssertEqual(event.statuses.count, 2)
        XCTAssertNotEqual(eventStatusOne, eventStatusTwo)

        event.insert(modelEventStatusTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Neither team should be deleted
        XCTAssertNotNil(eventStatusOne.managedObjectContext)
        XCTAssertEqual(eventStatusOne.event, event)

        XCTAssertNotNil(eventStatusTwo.managedObjectContext)
        XCTAssertEqual(eventStatusTwo.event, event)
    }

    func test_insert_teams() {
        let event = insertDistrictEvent()

        let modelTeamOne = TBATeam(key: "frc1", teamNumber: 1, name: "One", rookieYear: 2000)
        let modelTeamTwo = TBATeam(key: "frc2", teamNumber: 2, name: "Two", rookieYear: 2001)

        event.insert([modelTeamOne, modelTeamTwo])

        let teams = event.teams
        let teamOne = teams.first(where: { $0.key == "frc1" })!
        let teamTwo = teams.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.teams.count, 2)
        XCTAssertNotEqual(teamOne, teamTwo)

        event.insert([modelTeamTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.teams.onlyObject(teamTwo))

        // Neither team should be deleted
        XCTAssertNotNil(teamOne.managedObjectContext)
        XCTAssertNotNil(teamTwo.managedObjectContext)
    }

    func test_insert_webcasts() {
        let event = insertDistrictEvent()

        let modelWebcastOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let modelWebcastTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan2")

        event.insert([modelWebcastOne, modelWebcastTwo])

        let webcasts = event.webcasts
        let webcastOne = webcasts.first(where: { $0.channel == "firstinmichigan" })!
        let webcastTwo = webcasts.first(where: { $0.channel == "firstinmichigan2" })!

        // Sanity check
        XCTAssertEqual(event.webcasts.count, 2)
        XCTAssertNotEqual(webcastOne, webcastTwo)

        event.insert([modelWebcastTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Webcast updates it's relationships properly
        XCTAssert(event.webcasts.onlyObject(webcastTwo))

        // Webcast One should be deleted, since it's an orphan. Webcast Two should not be deleted.
        XCTAssertNil(webcastOne.managedObjectContext)
        XCTAssertNotNil(webcastTwo.managedObjectContext)
    }

    func event(type eventType: EventType) -> Event {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = eventType.rawValue as NSNumber
        return event
    }

    func test_isHappeningNow() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started two days ago, ends today
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDateRaw = calendar.date(byAdding: DateComponents(day: -2), to: today)
        event.endDateRaw = today
        XCTAssert(event.isHappeningNow)
    }

    func test_isHappeningNow_isNotHappening() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started three days ago, ended yesterday
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDateRaw = calendar.date(byAdding: DateComponents(day: -3), to: today)
        event.endDateRaw = calendar.date(byAdding: DateComponents(day: -1), to: today)
        XCTAssertFalse(event.isHappeningNow)
    }

    func test_isDistrictChampionshipEvent() {
        let dcmp = event(type: EventType.districtChampionship)
        XCTAssert(dcmp.isDistrictChampionshipEvent)
        XCTAssert(dcmp.isDistrictChampionship)

        let dcmpDivision = event(type: EventType.districtChampionshipDivision)
        XCTAssert(dcmpDivision.isDistrictChampionshipEvent)
        XCTAssertFalse(dcmpDivision.isDistrictChampionship)
    }

    func test_hybridType_regional() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.regional.rawValue,
                                                 startDate: nil,
                                                 district: nil), "0")
    }

    func test_hybridType_district() {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2022fim", year: 2022)
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.district.rawValue,
                                                 startDate: nil,
                                                 district: district), "1.fim")
    }

    func test_hybridType_districtChampionship() {
        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviationRaw = "fim"

        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.districtChampionship.rawValue,
                                                 startDate: nil,
                                                 district: nil), "2.dcmp")
    }

    func test_hybridType_championshipDivision() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.championshipDivision.rawValue,
                                                 startDate: nil,
                                                 district: nil), "3")
    }

    func test_hybridType_championshipFinals() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.championshipFinals.rawValue,
                                                 startDate: nil,
                                                 district: nil), "4")
    }

    func test_hybridType_districtChampionshipDivision() {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2022fim", year: 2022)
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.districtChampionshipDivision.rawValue,
                                                 startDate: nil,
                                                 district: district), "5..fim.dcmpd")
    }

    func test_hybridType_festivalOfChampions() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.festivalOfChampions.rawValue,
                                                 startDate: nil,
                                                 district: nil), "6")
    }

    func test_hybridType_offseason() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.offseason.rawValue,
                                                 startDate: Calendar.current.date(from: DateComponents(year: 2015, month: 11, day: 1)),
                                                 district: nil), "99.11")
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.offseason.rawValue,
                                                 startDate: Calendar.current.date(from: DateComponents(year: 2015, month: 9, day: 1)),
                                                 district: nil), "99.9")

        // Ensure single-digit month offseason events show up before double-digit month offseason events
        XCTAssert("99.9" > "99.11")
    }

    func test_hybridType_preseason() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.preseason.rawValue,
                                                 startDate: nil,
                                                 district: nil), "100")
    }

    func test_hybridType_unlabeled() {
        XCTAssertEqual(Event.calculateHybridType(eventType: EventType.unlabeled.rawValue,
                                                 startDate: nil,
                                                 district: nil), "-1")
    }

    func test_myTBASubscribable() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.keyRaw = "2018miket"

        XCTAssertEqual(event.modelKey, "2018miket")
        XCTAssertEqual(event.modelType, .event)
        XCTAssertEqual(Event.notificationTypes.count, 7)
    }

    func test_dateString_noDates() {
        let noDates = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(noDates.dateString())

        noDates.startDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNil(noDates.dateString())
        noDates.startDateRaw = nil

        noDates.endDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNil(noDates.dateString())

        noDates.startDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNotNil(noDates.dateString())
    }

    func test_dateString() {
        let sameDay = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameDay.startDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        sameDay.endDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertEqual(sameDay.dateString(), "Mar 05")

        let sameYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameYear.startDateRaw = Event.dateFormatter.date(from: "2018-03-01")!
        sameYear.endDateRaw = Event.dateFormatter.date(from: "2018-03-03")!
        XCTAssertEqual(sameYear.dateString(), "Mar 01 to Mar 03")

        let differentYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        differentYear.startDateRaw = Event.dateFormatter.date(from: "2018-12-31")!
        differentYear.endDateRaw = Event.dateFormatter.date(from: "2019-01-01")!
        XCTAssertEqual(differentYear.dateString(), "Dec 31 to Jan 01, 2019")
    }

    func test_dateString_timezone() {
        let timeZone = TimeZone(abbreviation: "UTC")!
        NSTimeZone.default = timeZone

        let sameYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameYear.startDateRaw = Event.dateFormatter.date(from: "2018-03-01")!
        sameYear.endDateRaw = Event.dateFormatter.date(from: "2018-03-03")!
        sameYear.timezoneRaw = "America/New_York"

        XCTAssertEqual(sameYear.dateString(), "Mar 01 to Mar 03")

        addTeardownBlock {
            NSTimeZone.resetSystemTimeZone()
        }
    }

    func test_awards_forTeamKey() {
        let event = insertDistrictEvent()

        // Insert one award, with one award recipient
        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key,
                                     recipients: [frc1Model],
                                     year: 2018)
        event.insert([modelAwardOne])

        // Sanity check
        XCTAssertEqual(event.awards.count, 1)

        let frc1TeamKey = Team.insert("frc1", in: persistentContainer.viewContext)
        let frc2TeamKey = Team.insert("frc2", in: persistentContainer.viewContext)

        // Should be one award for frc1
        XCTAssertEqual(event.awards(for: frc1TeamKey.key).count, 1)
        // Should be no awards for frc2
        XCTAssertEqual(event.awards(for: frc2TeamKey.key).count, 0)
    }

}
