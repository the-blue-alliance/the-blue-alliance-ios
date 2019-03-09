import XCTest
@testable import TBA

class EventTestCase: CoreDataTestCase {

    let calendar: Calendar = Calendar.current

    func test_insert_year() {
        let modelEventOne = TBAEvent(key: "2018miket", name: "name", eventCode: "code", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])
        let modelEventTwo = TBAEvent(key: "2018mike2", name: "name", eventCode: "code", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])

        Event.insert([modelEventOne, modelEventTwo], year: 2018, in: persistentContainer.viewContext)
        let eventsFirst = Event.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(Event.year), 2018)
        }

        let eventOne = eventsFirst.first(where: { $0.key == "2018miket" })!
        let eventTwo = eventsFirst.first(where: { $0.key == "2018mike2" })!

        // Sanity check
        XCTAssertNotEqual(eventOne, eventTwo)

        Event.insert([modelEventTwo], year: 2018, in: persistentContainer.viewContext)
        let eventsSecond = Event.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(Event.year), 2018)
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
                                  divisionKeys: ["2018mike1", "2018mike2", "2018mike3", "2018mike4"],
                                  parentEventKey: "2018mike2",
                                  playoffType: 1,
                                  playoffTypeString: "playoff string")

        let event = Event.insert(eventModel, in: persistentContainer.viewContext)

        XCTAssertEqual(event.key, "2018miket")
        XCTAssertEqual(event.name, "Name")
        XCTAssertEqual(event.eventCode, "miket")
        XCTAssertEqual(event.eventType, 1)
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
        XCTAssertEqual(event.webcasts?.count, 1)
        XCTAssertEqual(event.divisions?.count, 4)
        XCTAssertEqual(event.parentEvent?.key, "2018mike2")
        XCTAssertEqual(event.playoffType, 1)
        XCTAssertEqual(event.playoffTypeString, "playoff string")

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_alliances() {
        let event = insertDistrictEvent()

        let modelAllianceOne = TBAAlliance(name: "Alliance 1", picks: ["frc1"])
        let modelAllianceTwo = TBAAlliance(name: "Alliance 2", picks: ["frc2"])

        event.insert([modelAllianceOne, modelAllianceTwo])

        let alliances = event.alliances!.array as! [EventAlliance]
        let allianceOne = alliances.first(where: { $0.name == "Alliance 1" })!
        let allianceTwo = alliances.first(where: { $0.name == "Alliance 2" })!

        // Sanity check
        XCTAssertEqual(event.alliances?.count, 2)
        XCTAssertNotEqual(allianceOne, allianceTwo)

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc1
        event.insert([modelAllianceTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let alliancesSet = NSSet(array: event.alliances!.array)

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
                                     eventKey: event.key!,
                                     recipients: [frc1Model, frc2Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc2Model],
                                     year: 2018)

        event.insert([modelAwardOne, modelAwardTwo])

        let awards = event.awards!.allObjects as! [Award]
        let awardOne = awards.first(where: { $0.awardType?.intValue == 2 })!
        let awardTwo = awards.first(where: { $0.awardType?.intValue == 3 })!
        let frc1 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc1" })!
        let frc2 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.awards?.count, 2)
        XCTAssertNotEqual(awardOne, awardTwo)

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc1
        event.insert([modelAwardTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event has managed it's Award relationships properly
        XCTAssert(event.awards!.onlyObject(awardTwo))

        // First award should be deleted
        XCTAssertNil(awardOne.managedObjectContext)
        // Second award should not be deleted
        XCTAssertNotNil(awardTwo.managedObjectContext)

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssert(awardTwo.recipients!.onlyObject(frc2))

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
                                     eventKey: event.key!,
                                     recipients: [frc1Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc1Model],
                                     year: 2018)
        let modelAwardThree = TBAAward(name: "The Fake Award Three",
                                       awardType: 4,
                                       eventKey: event.key!,
                                       recipients: [frc2Model],
                                       year: 2018)

        event.insert([modelAwardOne, modelAwardTwo, modelAwardThree])

        let awards = event.awards!.allObjects as! [Award]
        let awardOne = awards.first(where: { $0.awardType?.intValue == 2 })!
        let awardTwo = awards.first(where: { $0.awardType?.intValue == 3 })!
        let awardThree = awards.first(where: { $0.awardType?.intValue == 4 })!

        let frc1TeamKey = TeamKey.findOrFetch(in: persistentContainer.viewContext, matching: NSPredicate(format: "%K == %@", #keyPath(TeamKey.key), frc1Model.teamKey!))!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let awardsFirst = Award.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "SUBQUERY(%K, $r, $r.teamKey.key == %@).@count == 1",
                                       #keyPath(Award.recipients), frc1TeamKey.key!)
        }

        // Sanity check
        XCTAssertNotEqual(awardOne, awardTwo)
        XCTAssertNotEqual(awardOne, awardThree)
        XCTAssertNotEqual(awardTwo, awardThree)

        XCTAssertEqual(event.awards?.count, 3)
        XCTAssertEqual(awardsFirst.count, 2)

        event.insert([modelAwardOne], teamKey: frc1TeamKey.key!)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let awardsSecond = Award.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "SUBQUERY(%K, $r, $r.teamKey.key == %@).@count == 1",
                                       #keyPath(Award.recipients), frc1TeamKey.key!)
        }

        XCTAssertEqual(event.awards?.count, 2)
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

        event.insert(model)

        let matches = event.matches!.allObjects as! [Match]
        let match = matches.first(where: { $0.key == "2018miket_sf2m3" })!

        // Sanity check
        XCTAssertEqual(event.matches?.count, 1)
        XCTAssertEqual(match.event, event)
    }

    func test_insert_matches() {
        let event = insertDistrictEvent()

        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let modelOne = TBAMatch(key: "\(event.key!)_sf2m3",
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

        let modelTwo = TBAMatch(key: "\(event.key!)_f1m1",
            compLevel: "f",
            setNumber: 1,
            matchNumber: 1,
            alliances: ["red": redAlliance, "blue": blueAlliance],
            winningAlliance: "blue",
            eventKey: event.key!,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        event.insert([modelOne, modelTwo])

        let matches = event.matches!.allObjects as! [Match]
        let matchOne = matches.first(where: { $0.key == "2018miket_sf2m3" })!
        let matchTwo = matches.first(where: { $0.key == "2018miket_f1m1" })!

        // Sanity check
        XCTAssertEqual(event.matches?.count, 2)
        XCTAssertNotEqual(matchOne, matchTwo)

        event.insert([modelTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.matches!.onlyObject(matchTwo))

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

        let rankings = event.rankings?.allObjects as! [EventRanking]
        let rankingOne = rankings.first(where: { $0.teamKey?.key == "frc1" })!
        let rankingTwo = rankings.first(where: { $0.teamKey?.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.rankings?.count, 2)
        XCTAssertNotEqual(rankingOne, rankingTwo)

        event.insert([modelRankingTwo], sortOrderInfo: nil, extraStatsInfo: nil)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.rankings!.onlyObject(rankingTwo))

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

        let stats = event.stats?.allObjects as! [EventTeamStat]
        let statsOne = stats.first(where: { $0.teamKey?.key == "frc1" })!
        let statsTwo = stats.first(where: { $0.teamKey?.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.stats?.count, 2)
        XCTAssertNotEqual(statsOne, statsTwo)

        event.insert([modelStatsTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.stats!.onlyObject(statsTwo))

        // StatsOne should be deleted
        XCTAssertNil(statsOne.managedObjectContext)

        // StatsTwo should not be deleted
        XCTAssertNotNil(statsTwo.managedObjectContext)
    }

    func test_insert_status() {
        let event = insertDistrictEvent()

        let modelEventStatusOne = TBAEventStatus(teamKey: "frc1", eventKey: event.key!, qual: TBAEventStatusQual(numTeams: nil, status: nil, ranking: TBAEventRanking(teamKey: "frc1", rank: 3), sortOrder: nil), alliance: nil, playoff: nil, allianceStatusString: nil, playoffStatusString: nil, overallStatusString: nil, nextMatchKey: nil, lastMatchKey: nil)
        let modelEventStatusTwo = TBAEventStatus(teamKey: "frc2", eventKey: event.key!)

        event.insert(modelEventStatusOne)
        event.insert(modelEventStatusTwo)

        let statuses = event.statuses!.allObjects as! [EventStatus]
        let eventStatusOne = statuses.first(where: { $0.teamKey?.key == "frc1" })!
        let eventStatusTwo = statuses.first(where: { $0.teamKey?.key == "frc2" })!

        // Ensure we setup a relationship to the ranking and the event properly
        XCTAssertEqual(eventStatusOne.qual?.ranking?.event, event)

        // Sanity check
        XCTAssertEqual(event.statuses?.count, 2)
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

        let teams = event.teams!.allObjects as! [Team]
        let teamOne = teams.first(where: { $0.key == "frc1" })!
        let teamTwo = teams.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.teams?.count, 2)
        XCTAssertNotEqual(teamOne, teamTwo)

        event.insert([modelTeamTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.teams!.onlyObject(teamTwo))

        // Neither team should be deleted
        XCTAssertNotNil(teamOne.managedObjectContext)
        XCTAssertNotNil(teamTwo.managedObjectContext)
    }

    func test_insert_webcasts() {
        let event = insertDistrictEvent()

        let modelWebcastOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let modelWebcastTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan2")

        event.insert([modelWebcastOne, modelWebcastTwo])

        let webcasts = event.webcasts!.allObjects as! [Webcast]
        let webcastOne = webcasts.first(where: { $0.channel == "firstinmichigan" })!
        let webcastTwo = webcasts.first(where: { $0.channel == "firstinmichigan2" })!

        // Sanity check
        XCTAssertEqual(event.webcasts?.count, 2)
        XCTAssertNotEqual(webcastOne, webcastTwo)

        event.insert([modelWebcastTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Webcast updates it's relationships properly
        XCTAssert(event.webcasts!.onlyObject(webcastTwo))

        // Webcast One should be deleted, since it's an orphan. Webcast Two should not be deleted.
        XCTAssertNil(webcastOne.managedObjectContext)
        XCTAssertNotNil(webcastTwo.managedObjectContext)
    }

    func test_isOrphaned() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        // Event should never be orphaned
        XCTAssertFalse(event.isOrphaned)
    }

    func event(type eventType: EventType) -> Event {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventType = eventType.rawValue as NSNumber
        return event
    }

    func test_isHappeningNow() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started two days ago, ends today
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDate = calendar.date(byAdding: DateComponents(day: -2), to: today)
        event.endDate = today
        XCTAssert(event.isHappeningNow)
    }

    func test_isHappeningNow_isNotHappening() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started three days ago, ended yesterday
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDate = calendar.date(byAdding: DateComponents(day: -3), to: today)
        event.endDate = calendar.date(byAdding: DateComponents(day: -1), to: today)
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
        let eventType = EventType.regional
        let regional = event(type: eventType)
        XCTAssertEqual(regional.calculateHybridType(), "0")
    }

    func test_hybridType_district() {
        let eventType = EventType.district
        let districtAbbreviation = "fim"

        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = districtAbbreviation

        let districtEvent = event(type: eventType)
        districtEvent.district = district

        XCTAssertEqual(districtEvent.calculateHybridType(), "1.fim")
    }

    func test_hybridType_districtChampionship() {
        let eventType = EventType.districtChampionship
        let districtChampionship = event(type: eventType)
        XCTAssertEqual(districtChampionship.calculateHybridType(), "2.dcmp")
    }

    func test_hybridType_championshipDivision() {
        let eventType = EventType.championshipDivision
        let championshipDivision = event(type: eventType)
        XCTAssertEqual(championshipDivision.calculateHybridType(), "3")
    }

    func test_hybridType_championshipFinals() {
        let eventType = EventType.championshipFinals
        let championshipFinals = event(type: eventType)
        XCTAssertEqual(championshipFinals.calculateHybridType(), "4")
    }

    func test_hybridType_districtChampionshipDivision() {
        let eventType = EventType.districtChampionshipDivision
        let districtAbbreviation = "fim"

        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = districtAbbreviation

        let districtChampionshipDivision = event(type: eventType)
        districtChampionshipDivision.district = district

        XCTAssertEqual(districtChampionshipDivision.calculateHybridType(), "2..fim.dcmpd")

        let districtChampionship = event(type: EventType.districtChampionship)
        // Ensure district championship divisions appear before district championships
        XCTAssert(districtChampionshipDivision.calculateHybridType() < districtChampionship.calculateHybridType())
    }

    func test_hybridType_festivalOfChampions() {
        let eventType = EventType.festivalOfChampions
        let festivalOfChampions = event(type: eventType)
        XCTAssertEqual(festivalOfChampions.calculateHybridType(), "6")
    }

    func test_hybridType_offseason() {
        let eventType = EventType.offseason

        let novermberOffseason = event(type: eventType)
        novermberOffseason.startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 11, day: 1))
        XCTAssertEqual(novermberOffseason.calculateHybridType(), "99.11")

        let septemberOffseason = event(type: eventType)
        septemberOffseason.startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 9, day: 1))
        XCTAssertEqual(septemberOffseason.calculateHybridType(), "99.9")

        // Ensure single-digit month offseason events show up before double-digit month offseason events
        XCTAssert(septemberOffseason.calculateHybridType() > novermberOffseason.calculateHybridType())
    }

    func test_hybridType_preseason() {
        let eventType = EventType.preseason
        let preseason = event(type: eventType)
        XCTAssertEqual(preseason.calculateHybridType(), "100")
    }

    func test_hybridType_unlabeled() {
        let eventType = EventType.unlabeled
        let unlabeled = event(type: eventType)
        XCTAssertEqual(unlabeled.calculateHybridType(), "-1")
    }

    func test_myTBASubscribable() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.key = "2018miket"

        XCTAssertEqual(event.modelKey, "2018miket")
        XCTAssertEqual(event.modelType, .event)
        XCTAssertEqual(Event.notificationTypes.count, 7)
    }

    func test_dateString_noDates() {
        let noDates = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(noDates.dateString())

        noDates.startDate = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNil(noDates.dateString())
        noDates.startDate = nil

        noDates.endDate = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNil(noDates.dateString())

        noDates.startDate = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNotNil(noDates.dateString())
    }

    func test_dateString() {
        let sameDay = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameDay.startDate = Event.dateFormatter.date(from: "2018-03-05")!
        sameDay.endDate = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertEqual(sameDay.dateString(), "Mar 05")

        let sameYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameYear.startDate = Event.dateFormatter.date(from: "2018-03-01")!
        sameYear.endDate = Event.dateFormatter.date(from: "2018-03-03")!
        XCTAssertEqual(sameYear.dateString(), "Mar 01 to Mar 03")

        let differentYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        differentYear.startDate = Event.dateFormatter.date(from: "2018-12-31")!
        differentYear.endDate = Event.dateFormatter.date(from: "2019-01-01")!
        XCTAssertEqual(differentYear.dateString(), "Dec 31 to Jan 01, 2019")
    }

    func test_dateString_timezone() {
        let timeZone = TimeZone(abbreviation: "UTC")!
        NSTimeZone.default = timeZone

        let sameYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameYear.startDate = Event.dateFormatter.date(from: "2018-03-01")!
        sameYear.endDate = Event.dateFormatter.date(from: "2018-03-03")!
        sameYear.timezone = "America/New_York"

        XCTAssertEqual(sameYear.dateString(), "Mar 01 to Mar 03")

        addTeardownBlock {
            NSTimeZone.resetSystemTimeZone()
        }
    }

}
