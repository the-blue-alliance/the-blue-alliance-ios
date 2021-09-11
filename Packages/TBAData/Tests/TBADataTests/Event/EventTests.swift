import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventTestCase: TBADataTestCase {

    func test_EventType_caseIterable() {
        XCTAssertFalse(EventType.allCases.isEmpty)
    }

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

    func test_alliances() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.alliances.array as! [EventAlliance], [])
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        event.alliancesRaw = NSOrderedSet(array: [alliance])
        XCTAssertEqual(event.alliances.array as! [EventAlliance], [alliance])
    }

    func test_awards() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.awards, [])
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        event.awardsRaw = NSSet(array: [award])
        XCTAssertEqual(event.awards, [award])
    }

    func test_district() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.district)
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        event.districtRaw = district
        XCTAssertEqual(event.district, district)
    }

    func test_divisions() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.divisions, [])
        let division = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.divisionsRaw = NSSet(array: [division])
        XCTAssertEqual(event.divisions, [division])
    }

    func test_insights() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.insights)
        let insights = EventInsights(entity: EventInsights.entity(), insertInto: persistentContainer.viewContext)
        event.insightsRaw = insights
        XCTAssertEqual(event.insights, insights)
    }

    func test_matches() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.matches, [])
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        event.matchesRaw = NSSet(array: [match])
        XCTAssertEqual(event.matches, [match])
    }

    func test_parentEvent() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.parentEvent)
        let parentEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.parentEventRaw = parentEvent
        XCTAssertEqual(event.parentEvent, parentEvent)
    }

    func test_points() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.points, [])
        let points = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        event.pointsRaw = NSSet(array: [points])
        XCTAssertEqual(event.points, [points])
    }

    func test_rankings() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.rankings, [])
        let rankings = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        event.rankingsRaw = NSSet(array: [rankings])
        XCTAssertEqual(event.rankings, [rankings])
    }

    func test_stats() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.stats, [])
        let stats = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        event.statsRaw = NSSet(array: [stats])
        XCTAssertEqual(event.stats, [stats])
    }

    func test_status() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(event.status)
        let status = Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext)
        event.statusRaw = status
        XCTAssertEqual(event.status, status)
    }

    func test_statuses() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.statuses, [])
        let status = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        event.statusesRaw = NSSet(array: [status])
        XCTAssertEqual(event.statuses, [status])
    }

    func test_teams() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.teams, [])
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        event.teamsRaw = NSSet(array: [team])
        XCTAssertEqual(event.teams, [team])
    }

    func test_webcasts() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.webcasts, [])
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: persistentContainer.viewContext)
        event.webcastsRaw = NSSet(array: [webcast])
        XCTAssertEqual(event.webcasts, [webcast])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<Event> = Event.fetchRequest()
        XCTAssertEqual(fr.entityName, Event.entityName)
    }

    func test_districtPredicate() {
        let district = insertDistrict()
        let predicate = Event.districtPredicate(districtKey: district.key)
        XCTAssertEqual(predicate.predicateFormat, "districtRaw.keyRaw == \"2018fim\"")

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        _ = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.districtRaw = district

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_champsYearPredicate() {
        let predicate = Event.champsYearPredicate(key: "2020cmpmi", year: 2020)
        XCTAssertEqual(predicate.predicateFormat, "yearRaw == 2020 AND ((eventTypeRaw == 4 OR eventTypeRaw == 3) AND (keyRaw == \"2020cmpmi\" OR parentEventRaw.keyRaw == \"2020cmpmi\"))")

        let parentEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        parentEvent.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        parentEvent.yearRaw = NSNumber(value: 2020)
        parentEvent.keyRaw = "2020cmpmi"
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        event.parentEventRaw = parentEvent
        event.keyRaw = "2020arc"
        event.yearRaw = NSNumber(value: 2020)
        let otherEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        otherEvent.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        otherEvent.keyRaw = "2020cmptx"
        otherEvent.yearRaw = NSNumber(value: 2020)

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssert(results.contains(parentEvent))
        XCTAssert(results.contains(event))
    }

    func test_eventTypeYearPredicate() {
        let predicate = Event.eventTypeYearPredicate(eventType: .district, year: 2020)
        XCTAssertEqual(predicate.predicateFormat, "yearRaw == 2020 AND eventTypeRaw == 1")

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.district.rawValue)
        event.yearRaw = NSNumber(value: 2020)
        let otherEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        otherEvent.eventTypeRaw = NSNumber(value: EventType.regional.rawValue)
        otherEvent.yearRaw = NSNumber(value: 2020)

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_offseasonYearPredicate() {
        let predicate = Event.offseasonYearPredicate(startDate: Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))!,
                                                     endDate: Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 31))!,
                                                     year: 2020)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.offseason.rawValue)
        event.startDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))
        event.endDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 3))
        event.yearRaw = NSNumber(value: 2020)
        let otherEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        otherEvent.eventTypeRaw = NSNumber(value: EventType.offseason.rawValue)
        otherEvent.startDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 4, day: 1))
        otherEvent.endDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 4, day: 3))
        otherEvent.yearRaw = NSNumber(value: 2020)

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_teamPredicate() {
        let predicate = Event.teamPredicate(teamKey: "frc7332")
        XCTAssertEqual(predicate.predicateFormat, "SUBQUERY(teamsRaw, $t, $t.keyRaw == \"frc7332\").@count > 0")

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        _ = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.keyRaw = "frc7332"
        event.teamsRaw = NSSet(array: [team])

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_teamYearPredicate() {
        let predicate = Event.teamYearPredicate(teamKey: "frc7332", year: 2020)
        XCTAssertEqual(predicate.predicateFormat, "SUBQUERY(teamsRaw, $t, $t.keyRaw == \"frc7332\").@count > 0 AND yearRaw == 2020")

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.yearRaw = NSNumber(value: 2020)
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.keyRaw = "frc7332"
        event.teamsRaw = NSSet(array: [team])

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_teamYearNonePredicate() {
        let predicate = Event.teamYearNonePredicate(teamKey: "frc7332")
        XCTAssertEqual(predicate.predicateFormat, "SUBQUERY(teamsRaw, $t, $t.keyRaw == \"frc7332\").@count > 0 AND yearRaw == -1")

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.yearRaw = NSNumber(value: 2020)
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.keyRaw = "frc7332"
        event.teamsRaw = NSSet(array: [team])

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [])
    }

    func test_unplayedEventPredicate() {
        let predicate = Event.unplayedEventPredicate(date: Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 31))!, year: 2020)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.yearRaw = NSNumber(value: 2020)
        event.endDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 4, day: 1))
        event.eventTypeRaw = NSNumber(value: EventType.district.rawValue)
        let otherEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        otherEvent.yearRaw = NSNumber(value: 2020)
        otherEvent.endDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 4, day: 1))
        otherEvent.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        let thirdEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        thirdEvent.yearRaw = NSNumber(value: 2020)
        thirdEvent.endDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 30))
        thirdEvent.eventTypeRaw = NSNumber(value: EventType.district.rawValue)

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_weekYearPredicate() {
        let predicate = Event.weekYearPredicate(week: 1, year: 2020)
        XCTAssertEqual(predicate.predicateFormat, "yearRaw == 2020 AND weekRaw == 1")

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.weekRaw = NSNumber(value: 1)
        event.yearRaw = NSNumber(value: 2020)
        let otherEvent = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        otherEvent.weekRaw = NSNumber(value: 0)
        otherEvent.yearRaw = NSNumber(value: 2020)

        let results = Event.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [event])
    }

    func test_yearPredicate() {
        let p = Event.yearPredicate(year: 2020)
        XCTAssertEqual(p.predicateFormat, "yearRaw == 2020")
    }

    func test_unknownYearPredicate() {
        let p = Event.unknownYearPredicate(year: 2021)
        XCTAssertEqual(p.predicateFormat, "yearRaw == 2021 AND (NOT eventTypeRaw IN {0, 1, 2, 3, 4, 5, 6, 99, 100, -1})")
    }
    
    func test_nonePredicate() {
        let p = Event.nonePredicate()
        XCTAssertEqual(p.predicateFormat, "yearRaw == -1")
    }

    func test_sortDescriptors() {
        let one = Event.startDateSortDescriptor()
        let two = Event.nameSortDescriptor()
        let sd = Event.sortDescriptors()
        XCTAssert(sd.contains(one))
        XCTAssert(sd.contains(two))
    }

    func test_endDateSortDescriptor() {
        let sd = Event.endDateSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Event.endDateRaw))
        XCTAssert(sd.ascending)
    }

    func test_hybridTypeSortDescriptor() {
        let sd = Event.hybridTypeSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Event.hybridType))
        XCTAssert(sd.ascending)
    }

    func test_nameSortDescriptor() {
        let sd = Event.nameSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Event.nameRaw))
        XCTAssert(sd.ascending)
    }

    func test_startDateSortDescriptor() {
        let sd = Event.startDateSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Event.startDateRaw))
        XCTAssert(sd.ascending)
    }

    func test_weekSortDescriptor() {
        let sd = Event.weekSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Event.weekRaw))
        XCTAssert(sd.ascending)
    }

    func test_hybridTypeKeyPath() {
        let kp = Event.hybridTypeKeyPath()
        XCTAssertEqual(kp, #keyPath(Event.hybridType))
    }

    func test_weekKeyPath() {
        let kp = Event.weekKeyPath()
        XCTAssertEqual(kp, #keyPath(Event.weekRaw))
    }

    func test_populatedEventsPredicate() {
        let p = Event.populatedEventsPredicate()
        XCTAssertEqual(p.predicateFormat, "endDateRaw != nil AND eventCodeRaw != nil AND eventTypeRaw != nil AND keyRaw != nil AND nameRaw != nil AND startDateRaw != nil AND yearRaw != nil")
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

    func test_isHappeningNow_none() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isHappeningNow)
    }

    func test_isHappeningNow() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started two days ago, ends today
        let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDateRaw = Calendar.current.date(byAdding: DateComponents(day: -2), to: today)
        event.endDateRaw = today
        XCTAssert(event.isHappeningNow)
    }

    func test_isHappeningNow_isNotHappening() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started three days ago, ended yesterday
        let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDateRaw = Calendar.current.date(byAdding: DateComponents(day: -3), to: today)
        event.endDateRaw = Calendar.current.date(byAdding: DateComponents(day: -1), to: today)
        XCTAssertFalse(event.isHappeningNow)
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
                                                 district: district), "2..fim.dcmpd")
    }

    func test_hybridType_districtChampionshipDivision_sort() {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2022fim", year: 2022)
        let dcmpd = Event.calculateHybridType(eventType: EventType.districtChampionshipDivision.rawValue,
                                              startDate: nil,
                                              district: district)
        let dcmp = Event.calculateHybridType(eventType: EventType.districtChampionship.rawValue,
                                             startDate: nil,
                                             district: district)
        let cmpd = Event.calculateHybridType(eventType: EventType.championshipDivision.rawValue,
                                             startDate: nil,
                                             district: nil)
        let cmp = Event.calculateHybridType(eventType: EventType.championshipFinals.rawValue,
                                            startDate: nil,
                                            district: nil)
        XCTAssertEqual([cmp, dcmp, dcmpd, cmpd].sorted(), [dcmpd, dcmp, cmpd, cmp])
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
                                                 district: nil), "99.09")

        // Ensure single-digit month offseason events show up before double-digit month offseason events
        XCTAssert("99.09" < "99.11")
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
        XCTAssertNil(noDates.dateString)

        noDates.startDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNil(noDates.dateString)
        noDates.startDateRaw = nil

        noDates.endDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNil(noDates.dateString)

        noDates.startDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertNotNil(noDates.dateString)
    }

    func test_dateString() {
        let sameDay = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameDay.startDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        sameDay.endDateRaw = Event.dateFormatter.date(from: "2018-03-05")!
        XCTAssertEqual(sameDay.dateString, "Mar 05")

        let sameYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameYear.startDateRaw = Event.dateFormatter.date(from: "2018-03-01")!
        sameYear.endDateRaw = Event.dateFormatter.date(from: "2018-03-03")!
        XCTAssertEqual(sameYear.dateString, "Mar 01 to Mar 03")

        let differentYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        differentYear.startDateRaw = Event.dateFormatter.date(from: "2018-12-31")!
        differentYear.endDateRaw = Event.dateFormatter.date(from: "2019-01-01")!
        XCTAssertEqual(differentYear.dateString, "Dec 31 to Jan 01, 2019")
    }

    func test_dateString_timezone() {
        let timeZone = TimeZone(abbreviation: "UTC")!
        NSTimeZone.default = timeZone

        let sameYear = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        sameYear.startDateRaw = Event.dateFormatter.date(from: "2018-03-01")!
        sameYear.endDateRaw = Event.dateFormatter.date(from: "2018-03-03")!
        sameYear.timezoneRaw = "America/New_York"

        XCTAssertEqual(sameYear.dateString, "Mar 01 to Mar 03")

        addTeardownBlock {
            NSTimeZone.resetSystemTimeZone()
        }
    }

    func test_weekString_noEventType() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(event.weekString, "Unknown")
    }

    func test_weekString_championship() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        // CMP/CMP Finals, pre-2017
        event.yearRaw = NSNumber(value: 2016)
        event.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        XCTAssertEqual(event.weekString, "Championship")
        event.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        XCTAssertEqual(event.weekString, "Championship")

        // CMP/CMP Finals, post-2017 (#2champs)
        event.yearRaw = NSNumber(value: 2017)
        event.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        // No city
        event.cityRaw = nil
        XCTAssertEqual(event.weekString, "Championship")
        event.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        XCTAssertEqual(event.weekString, "Championship")

        // City
        event.cityRaw = "Detroit"
        event.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        XCTAssertEqual(event.weekString, "Championship - Detroit")
        event.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        XCTAssertEqual(event.weekString, "Championship - Detroit")
    }

    func test_weekString_unlabeled() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.unlabeled.rawValue)
        XCTAssertEqual(event.weekString, "Other")
    }

    func test_weekString_preseason() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.preseason.rawValue)
        XCTAssertEqual(event.weekString, "Preseason")
    }

    func test_weekString_offseason() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.offseason.rawValue)
        XCTAssertEqual(event.weekString, "Offseason")

        event.startDateRaw = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))
        XCTAssertEqual(event.weekString, "March Offseason")
    }

    func test_weekString_festivalOfChampions() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.festivalOfChampions.rawValue)
        XCTAssertEqual(event.weekString, "Festival of Champions")
    }

    func test_weekString_week() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: EventType.district.rawValue)
        // No week
        XCTAssertEqual(event.weekString, "Other")
        // 2016 week 0
        event.yearRaw = NSNumber(value: 2016)
        event.weekRaw = NSNumber(value: 0)
        XCTAssertEqual(event.weekString, "Week 0.5")
        event.weekRaw = NSNumber(value: 1)
        XCTAssertEqual(event.weekString, "Week 1")
        // Other years - regular
        event.yearRaw = NSNumber(value: 2017)
        event.weekRaw = NSNumber(value: 0)
        XCTAssertEqual(event.weekString, "Week 1")
        event.weekRaw = NSNumber(value: 1)
        XCTAssertEqual(event.weekString, "Week 2")
    }

    func test_safeNameYear() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.yearRaw = NSNumber(value: 2019)
        event.keyRaw = "2019miket"
        // No name - use key
        XCTAssertEqual(event.safeNameYear, "2019miket")
        // Empty name - use key
        event.nameRaw = ""
        XCTAssertEqual(event.safeNameYear, "2019miket")
        // Name - use name
        event.nameRaw = "FIM District Kettering University Event #1"
        XCTAssertEqual(event.safeNameYear, "2019 FIM District Kettering University Event #1")
    }

    func test_safeShortName() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.keyRaw = "2019miket"
        // No name - use key
        XCTAssertEqual(event.safeShortName, "2019miket")
        // Name - use name
        event.nameRaw = "FIM District Kettering University Event #1"
        XCTAssertEqual(event.safeShortName, "FIM District Kettering University Event #1")
        // Short name - but empty
        event.shortNameRaw = ""
        XCTAssertEqual(event.safeShortName, "FIM District Kettering University Event #1")
        // Short name - use short name
        event.shortNameRaw = "Kettering University #1"
        XCTAssertEqual(event.safeShortName, "Kettering University #1")
    }

    func test_friendlyNameWithYear() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.keyRaw = "2019miket"
        event.yearRaw = NSNumber(value: 2019)
        // No info
        XCTAssertEqual(event.friendlyNameWithYear, "2019miket")
        // Name
        event.nameRaw = "FIM District Kettering University Event #1"
        XCTAssertEqual(event.friendlyNameWithYear, "2019 FIM District Kettering University Event #1")
        // Short name
        event.shortNameRaw = "Kettering University #1"
        XCTAssertEqual(event.friendlyNameWithYear, "2019 Kettering University #1 Event")
        // Event type
        event.eventTypeStringRaw = "District"
        XCTAssertEqual(event.friendlyNameWithYear, "2019 Kettering University #1 District")
    }

    func test_isChampionshipEvent() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isChampionshipEvent)
        event.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        XCTAssertTrue(event.isChampionshipEvent)
        event.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        XCTAssertTrue(event.isChampionshipEvent)
    }

    func test_isChampionshipDivision() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isChampionshipEvent)
        event.eventTypeRaw = NSNumber(value: EventType.championshipDivision.rawValue)
        XCTAssertTrue(event.isChampionshipDivision)
    }

    func test_isChampionshipFinals() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isChampionshipEvent)
        event.eventTypeRaw = NSNumber(value: EventType.championshipFinals.rawValue)
        XCTAssertTrue(event.isChampionshipFinals)
    }

    func test_isDistrictChampionshipEvent() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isDistrictChampionshipEvent)
        event.eventTypeRaw = NSNumber(value: EventType.districtChampionshipDivision.rawValue)
        XCTAssertTrue(event.isDistrictChampionshipEvent)
        event.eventTypeRaw = NSNumber(value: EventType.districtChampionship.rawValue)
        XCTAssertTrue(event.isDistrictChampionshipEvent)
    }

    func test_isDistrictChampionshipDivision() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isDistrictChampionshipDivision)
        event.eventTypeRaw = NSNumber(value: EventType.districtChampionshipDivision.rawValue)
        XCTAssertTrue(event.isDistrictChampionshipDivision)
    }

    func test_isDistrictChampionship() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isDistrictChampionship)
        event.eventTypeRaw = NSNumber(value: EventType.districtChampionship.rawValue)
        XCTAssertTrue(event.isDistrictChampionship)
    }

    func test_isFoC() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isFoC)
        event.eventTypeRaw = NSNumber(value: EventType.festivalOfChampions.rawValue)
        XCTAssertTrue(event.isFoC)
    }

    func test_isPreseason() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isPreseason)
        event.eventTypeRaw = NSNumber(value: EventType.preseason.rawValue)
        XCTAssertTrue(event.isPreseason)
    }

    func test_isOffseason() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isOffseason)
        event.eventTypeRaw = NSNumber(value: EventType.offseason.rawValue)
        XCTAssertTrue(event.isOffseason)
    }

    func test_isRegional() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isRegional)
        event.eventTypeRaw = NSNumber(value: EventType.regional.rawValue)
        XCTAssertTrue(event.isRegional)
    }

    func test_isUnlabeled() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(event.isUnlabeled)
        event.eventTypeRaw = NSNumber(value: EventType.unlabeled.rawValue)
        XCTAssertTrue(event.isUnlabeled)
    }

    func _test_event(type: EventType, week: Int?, year: Int) -> Event {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventTypeRaw = NSNumber(value: type.rawValue)
        if let week = week {
            event.weekRaw = NSNumber(value: week)
        }
        event.yearRaw = NSNumber(value: year)
        return event
    }

    func test_comparable_keys() {
        let one = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        one.keyRaw = "2020a"
        one.yearRaw = NSNumber(value: 2020)
        let two = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        two.keyRaw = "2020b"
        two.yearRaw = NSNumber(value: 2020)
        XCTAssert(one < two)
    }

    func test_comparable() {
        let future = _test_event(type: .preseason, week: nil, year: 2020)
        let preseason = _test_event(type: .preseason, week: nil, year: 2017)
        preseason.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 2, day: 24))!
        let preseasonLater = _test_event(type: .preseason, week: nil, year: 2017)
        preseasonLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 2, day: 25))!
        let zero = _test_event(type: .regional, week: 0, year: 2017)
        let one = _test_event(type: .regional, week: 1, year: 2017)
        one.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 3, day: 1))!
        let oneLater = _test_event(type: .regional, week: 1, year: 2017)
        oneLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 3, day: 3))!
        let two = _test_event(type: .district, week: 2, year: 2017)
        let three = _test_event(type: .regional, week: 3, year: 2017)
        let four = _test_event(type: .regional, week: 4, year: 2017)
        let five = _test_event(type: .district, week: 5, year: 2017)
        let fiveDCMP = _test_event(type: .districtChampionship, week: 5, year: 2017)
        fiveDCMP.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 1))!
        let fiveDCMPLater = _test_event(type: .districtChampionship, week: 5, year: 2017)
        fiveDCMPLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 2))!
        let six = _test_event(type: .regional, week: 6, year: 2017)
        let sixDistrict = _test_event(type: .district, week: 6, year: 2017)
        let sixDCMP = _test_event(type: .districtChampionship, week: 6, year: 2017)
        let sixDCMPDivision = _test_event(type: .districtChampionshipDivision, week: 6, year: 2017)
        sixDCMPDivision.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 20))!
        let sixDCMPDivisionLater = _test_event(type: .districtChampionshipDivision, week: 6, year: 2017)
        sixDCMPDivisionLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 21))!
        let cmp = _test_event(type: .championshipFinals, week: nil, year: 2017)
        cmp.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 22))!
        let cmpLater = _test_event(type: .championshipFinals, week: nil, year: 2017)
        cmpLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 29))!
        let cmpDivision = _test_event(type: .championshipDivision, week: nil, year: 2017)
        cmpDivision.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 22))!
        let cmpDivisionLater = _test_event(type: .championshipDivision, week: nil, year: 2017)
        cmpDivisionLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 23))!
        let foc = _test_event(type: .festivalOfChampions, week: nil, year: 2017)
        foc.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 7, day: 29))!
        let focLater = _test_event(type: .festivalOfChampions, week: nil, year: 2017)
        focLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 7, day: 30))!
        let offseason = _test_event(type: .offseason, week: 0, year: 2017)
        offseason.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 6, day: 1))!
        let offseasonLater = _test_event(type: .offseason, week: 0, year: 2017)
        offseasonLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 7, day: 1))!
        let unlabeled = _test_event(type: .unlabeled, week: nil, year: 2017)
        unlabeled.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 10, day: 1))!
        let unlabeledLater = _test_event(type: .unlabeled, week: nil, year: 2017)
        unlabeledLater.startDateRaw = Calendar.current.date(from: DateComponents(year: 2017, month: 10, day: 3))!

        XCTAssert(preseason < future)
        XCTAssert(preseason < offseason)
        XCTAssert(preseason < preseasonLater)
        XCTAssert(preseason < zero)
        XCTAssert(zero < one)
        XCTAssert(one < oneLater)
        XCTAssert(one < two)
        XCTAssert(two < three)
        XCTAssert(three < four)
        XCTAssert(four < five)
        XCTAssert(five < six)
        XCTAssert(five < fiveDCMP)
        XCTAssert(fiveDCMP < fiveDCMPLater)
        XCTAssert(six < sixDCMP)
        XCTAssert(six < sixDistrict)
        XCTAssert(sixDistrict < sixDCMPDivision)
        XCTAssert(sixDistrict < sixDCMP)
        XCTAssert(sixDCMPDivision < sixDCMP)
        XCTAssert(fiveDCMP < sixDCMP)
        XCTAssert(fiveDCMP < cmp)
        XCTAssert(sixDCMPDivision < sixDCMPDivisionLater)
        XCTAssert(sixDCMPDivision < cmpDivision)
        XCTAssert(sixDCMP < cmpDivision)
        XCTAssert(cmpDivision < cmpDivisionLater)
        XCTAssert(sixDCMPDivision < cmp)
        XCTAssert(sixDCMP < cmp)
        XCTAssert(cmpDivision < cmp)
        XCTAssert(cmp < cmpLater)
        XCTAssert(cmp < foc)
        XCTAssert(foc < focLater)
        XCTAssert(cmp < unlabeled)
        XCTAssert(foc < offseason)
        XCTAssert(offseason < offseasonLater)
        XCTAssert(offseason < unlabeled)
        XCTAssert(two < unlabeled)
        XCTAssert(two < offseason)
        XCTAssert(unlabeled < unlabeledLater)

        let allEvents = [future, preseason, preseasonLater, zero, one, oneLater, two, three, four, five, fiveDCMP, fiveDCMPLater, six, sixDistrict, sixDCMP, sixDCMPDivision, sixDCMPDivisionLater, cmp, cmpLater, cmpDivision, cmpDivisionLater, foc, focLater, offseason, offseasonLater, unlabeled, unlabeledLater]
        XCTAssertEqual(allEvents.sorted(), [preseason, preseasonLater, zero, one, oneLater, two, three, four, five, fiveDCMP, fiveDCMPLater, six, sixDistrict, sixDCMPDivision, sixDCMPDivisionLater, sixDCMP, cmpDivision, cmpDivisionLater, cmp, cmpLater, foc, focLater, offseason, offseasonLater, unlabeled, unlabeledLater, future])
    }

}
