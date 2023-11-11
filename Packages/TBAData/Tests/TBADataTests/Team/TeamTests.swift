import CoreData
import TBAKit
import XCTest
@testable import TBAData

class TeamTestCase: TBADataTestCase {

    func test_address() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.address)
        team.addressRaw = "address"
        XCTAssertEqual(team.address, "address")
    }

    func test_city() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.city)
        team.cityRaw = "city"
        XCTAssertEqual(team.city, "city")
    }

    func test_country() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.country)
        team.countryRaw = "country"
        XCTAssertEqual(team.country, "country")
    }

    func test_gmapsPlaceID() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.gmapsPlaceID)
        team.gmapsPlaceIDRaw = "gmapsPlaceID"
        XCTAssertEqual(team.gmapsPlaceID, "gmapsPlaceID")
    }

    func test_gmapsURL() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.gmapsURL)
        team.gmapsURLRaw = "gmapsURL"
        XCTAssertEqual(team.gmapsURL, "gmapsURL")
    }

    func test_homeChampionship() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.homeChampionship)
        team.homeChampionshipRaw = ["2019": "Detroit"]
        XCTAssertEqual(team.homeChampionship, ["2019": "Detroit"])
    }

    func test_key() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.keyRaw = "key"
        XCTAssertEqual(team.key, "key")
    }

    func test_lat() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.lat)
        team.latRaw = NSNumber(value: 101.102)
        XCTAssertEqual(team.lat, 101.102)
    }

    func test_lng() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.lng)
        team.lngRaw = NSNumber(value: 101.102)
        XCTAssertEqual(team.lng, 101.102)
    }

    func test_locationName() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.locationName)
        team.locationNameRaw = "locationName"
        XCTAssertEqual(team.locationName, "locationName")
    }

    func test_name() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.name)
        team.nameRaw = "name"
        XCTAssertEqual(team.name, "name")
    }

    func test_nickname() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.nickname)
        team.nicknameRaw = "nickname"
        XCTAssertEqual(team.nickname, "nickname")
    }

    func test_postalCode() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.postalCode)
        team.postalCodeRaw = "postalCode"
        XCTAssertEqual(team.postalCode, "postalCode")
    }

    func test_rookieYear() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.rookieYear)
        team.rookieYearRaw = 2008
        XCTAssertEqual(team.rookieYear, 2008)
    }

    func test_schoolName() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.schoolName)
        team.schoolNameRaw = "schoolName"
        XCTAssertEqual(team.schoolName, "schoolName")
    }

    func test_stateProv() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.stateProv)
        team.stateProvRaw = "stateProv"
        XCTAssertEqual(team.stateProv, "stateProv")
    }

    func test_teamNumber() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.teamNumberRaw = NSNumber(value: 7332)
        XCTAssertEqual(team.teamNumber, 7332)
    }

    func test_website() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.website)
        team.websiteRaw = "website"
        XCTAssertEqual(team.website, "website")
    }

    func test_yearsParticipated() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(team.yearsParticipated)
        team.yearsParticipatedRaw = [2019, 2018, 2020]
        XCTAssertEqual(team.yearsParticipated, [2020, 2019, 2018])
    }

    func test_setYearsParticipated() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.setYearsParticipated([2019, 2018, 2020])
        XCTAssertEqual(team.yearsParticipated, [2020, 2019, 2018])
    }

    func test_alliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.alliances, [])
        let a = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        team.alliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.alliances, [a])
    }

    func test_awards() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.awards, [])
        let a = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)
        team.awardsRaw = NSSet(array: [a])
        XCTAssertEqual(team.awards, [a])
    }

    func test_declinedAlliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.declinedAlliances, [])
        let a = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        team.declinedAlliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.declinedAlliances, [a])
    }

    func test_districtRankings() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.districtRankings, [])
        let a = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        team.districtRankingsRaw = NSSet(array: [a])
        XCTAssertEqual(team.districtRankings, [a])
    }

    func test_districts() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.districts, [])
        let a = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        team.districtsRaw = NSSet(array: [a])
        XCTAssertEqual(team.districts, [a])
    }

    func test_dqAlliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.dqAlliances, [])
        let a = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        team.dqAlliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.dqAlliances, [a])
    }

    func test_eventPoints() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.eventPoints, [])
        let a = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        team.eventPointsRaw = NSSet(array: [a])
        XCTAssertEqual(team.eventPoints, [a])
    }

    func test_eventRankings() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.eventRankings, [])
        let a = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        team.eventRankingsRaw = NSSet(array: [a])
        XCTAssertEqual(team.eventRankings, [a])
    }

    func test_events() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.events, [])
        let a = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        team.eventsRaw = NSSet(array: [a])
        XCTAssertEqual(team.events, [a])
    }

    func test_eventStatuses() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.eventStatuses, [])
        let a = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        team.eventStatusesRaw = NSSet(array: [a])
        XCTAssertEqual(team.eventStatuses, [a])
    }

    func test_inBackupAlliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.inBackupAlliances, [])
        let a = EventAllianceBackup.init(entity: EventAllianceBackup.entity(), insertInto: persistentContainer.viewContext)
        team.inBackupAlliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.inBackupAlliances, [a])
    }

    func test_media() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.media, [])
        let a = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        team.mediaRaw = NSSet(array: [a])
        XCTAssertEqual(team.media, [a])
    }

    func test_outBackupAlliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.outBackupAlliances, [])
        let a = EventAllianceBackup.init(entity: EventAllianceBackup.entity(), insertInto: persistentContainer.viewContext)
        team.outBackupAlliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.outBackupAlliances, [a])
    }

    func test_pickedAlliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.pickedAlliances, [])
        let a = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        team.pickedAlliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.pickedAlliances, [a])
    }

    func test_stats() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.stats, [])
        let a = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        team.statsRaw = NSSet(array: [a])
        XCTAssertEqual(team.stats, [a])
    }

    func test_surrogateAlliances() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.surrogateAlliances, [])
        let a = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        team.surrogateAlliancesRaw = NSSet(array: [a])
        XCTAssertEqual(team.surrogateAlliances, [a])
    }

    func test_zebra() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(team.zebra, [])
        let zebra = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        team.zebraRaw = NSSet(array: [zebra])
        XCTAssertEqual(team.zebra, [zebra])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<Team> = Team.fetchRequest()
        XCTAssertEqual(fr.entityName, Team.entityName)
    }

    func test_predicate() {
        let predicate = Team.predicate(key: "frc7332")
        XCTAssertEqual(predicate.predicateFormat, "keyRaw == \"frc7332\"")
    }

    func test_districtPredicate() {
        let district = insertDistrict()
        let predicate = Team.districtPredicate(districtKey: district.key)
        XCTAssertEqual(predicate.predicateFormat, "ANY districtsRaw.keyRaw == \"2018fim\"")

        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.districtsRaw = NSSet(array: [district])
        _ = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)

        let results = Team.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [team])
    }

    func test_eventPredicate() {
        let event = insertEvent()
        let predicate = Team.eventPredicate(eventKey: event.key)
        XCTAssertEqual(predicate.predicateFormat, "ANY eventsRaw.keyRaw == \"2015qcmo\"")

        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.eventsRaw = NSSet(array: [event])
        _ = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)

        let results = Team.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [team])
    }

    func test_searchPredicate() {
        let predicate = Team.searchPredicate(searchText: "abc")
        XCTAssertEqual(predicate.predicateFormat, "nicknameRaw CONTAINS[cd] \"abc\" OR teamNumberRaw.stringValue BEGINSWITH[cd] \"abc\" OR cityRaw CONTAINS[cd] \"abc\"")
    }

    func test_searchKeyPathPredicate() {
        let predicate = Team.searchKeyPathPredicate(
            nicknameKeyPath: #keyPath(Team.nicknameRaw),
            teamNumberKeyPath: #keyPath(Team.teamNumberRaw.stringValue),
            cityKeyPath: #keyPath(Team.cityRaw),
            searchText: "abc"
        )

        XCTAssertEqual(predicate.predicateFormat, "nicknameRaw CONTAINS[cd] \"abc\" OR teamNumberRaw.stringValue BEGINSWITH[cd] \"abc\" OR cityRaw CONTAINS[cd] \"abc\"")
    }

    func test_teamNumberSortDescriptor() {
        let sd = Team.teamNumberSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Team.teamNumberRaw))
        XCTAssert(sd.ascending)
    }

    func test_populatedTeamsPredicate() {
        let predicate = Team.populatedTeamsPredicate()
        XCTAssertEqual(predicate.predicateFormat, "keyRaw != nil AND nameRaw != nil")

        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz")
        let team = Team.insert(model, in: persistentContainer.viewContext)
        _ = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)

        let results = Team.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [team])
    }

    func test_trimFRCPrefix() {
        XCTAssertEqual(Team.trimFRCPrefix("frc2337"), "2337")
        XCTAssertEqual(Team.trimFRCPrefix("frc2337b"), "2337B")
    }

    func test_insert_all() {
        let modelOne = TBATeam(key: "frc1", teamNumber: 1, name: "1", rookieYear: 2008)
        let modelTwo = TBATeam(key: "frc2", teamNumber: 2, name: "2", rookieYear: 2008)

        Team.insert([modelOne, modelTwo], in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsFirst = Team.fetch(in: persistentContainer.viewContext)

        let teamOne = teamsFirst.first(where: { $0.key == "frc1" })!
        let teamTwo = teamsFirst.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertNotEqual(teamOne, teamTwo)
        XCTAssertEqual(teamsFirst.count, 2)

        // Make sure both previous teams are deleted
        let modelThree = TBATeam(key: "frc500", teamNumber: 500, name: "500", rookieYear: 2008)
        Team.insert([modelThree], in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsSecond = Team.fetch(in: persistentContainer.viewContext)

        XCTAssertEqual(teamsSecond.count, 1)
        XCTAssertEqual(teamsSecond.first!.key, "frc500")

        Team.insert([], in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsThird = Team.fetch(in: persistentContainer.viewContext)

        XCTAssertEqual(teamsThird.count, 0)
    }

    func test_insert_page() {
        let modelOne = TBATeam(key: "frc1", teamNumber: 1, name: "1", rookieYear: 2008)
        let modelTwo = TBATeam(key: "frc2", teamNumber: 2, name: "2", rookieYear: 2008)

        Team.insert([modelOne, modelTwo], page: 0, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsFirst = Team.fetch(in: persistentContainer.viewContext)

        let teamOne = teamsFirst.first(where: { $0.key == "frc1" })!
        let teamTwo = teamsFirst.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertNotEqual(teamOne, teamTwo)
        XCTAssertEqual(teamsFirst.count, 2)

        // Make sure no teams are deleted, since it's not the right page
        let modelThree = TBATeam(key: "frc500", teamNumber: 500, name: "500", rookieYear: 2008)
        Team.insert([modelThree], page: 1, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsSecond = Team.fetch(in: persistentContainer.viewContext)

        XCTAssertEqual(teamsSecond.count, 3)

        Team.insert([], page: 1, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsThird = Team.fetch(in: persistentContainer.viewContext)

        XCTAssertEqual(teamsThird.count, 2)

        Team.insert([modelTwo], page: 0, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teamsFour = Team.fetch(in: persistentContainer.viewContext)

        XCTAssertEqual(teamsFour, [teamTwo])

        XCTAssertNil(teamOne.managedObjectContext)
        XCTAssertNotNil(teamTwo.managedObjectContext)
    }

    func test_insert() {
        let model = TBATeam(key: "frc7332",
                            teamNumber: 7332,
                            nickname: "The Rawrbotz",
                            name: "The first ever FRC team sponsored by small donors",
                            schoolName: "Blue Alliance High School",
                            city: "Anytown",
                            stateProv: "MI",
                            country: "USA",
                            address: "123 Some Street",
                            postalCode: "48439",
                            gmapsPlaceID: "id",
                            gmapsURL: "url",
                            lat: 1.1,
                            lng: 2.1,
                            locationName: "location",
                            website: "http://website.com",
                            rookieYear: 2010,
                            homeChampionship: ["2018": "Detroit"])
        let team = Team.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(team.key, "frc7332")
        XCTAssertEqual(team.teamNumber, 7332)
        XCTAssertEqual(team.nickname, "The Rawrbotz")
        XCTAssertEqual(team.name, "The first ever FRC team sponsored by small donors")
        XCTAssertEqual(team.schoolName, "Blue Alliance High School")
        XCTAssertEqual(team.city, "Anytown")
        XCTAssertEqual(team.stateProv, "MI")
        XCTAssertEqual(team.country, "USA")
        XCTAssertEqual(team.address, "123 Some Street")
        XCTAssertEqual(team.postalCode, "48439")
        XCTAssertEqual(team.gmapsPlaceID, "id")
        XCTAssertEqual(team.gmapsURL, "url")
        XCTAssertEqual(team.lat, 1.1)
        XCTAssertEqual(team.lng, 2.1)
        XCTAssertEqual(team.locationName, "location")
        XCTAssertEqual(team.website, "http://website.com")
        XCTAssertEqual(team.rookieYear, 2010)
        XCTAssertEqual(team.homeChampionship, ["2018": "Detroit"])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_events() {
        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)

        let modelEventOne = TBAEvent(key: "2018miket", name: "Event 1", eventCode: "miket", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])
        let modelEventTwo = TBAEvent(key: "2018mike2", name: "Event 2", eventCode: "mike2", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])

        team.insert([modelEventOne, modelEventTwo])

        let events = team.events
        let eventOne = events.first(where: { $0.key == "2018miket" })!
        let eventTwo = events.first(where: { $0.key == "2018mike2" })!

        // Sanity check
        XCTAssertEqual(team.events.count, 2)
        XCTAssertNotEqual(eventOne, eventTwo)

        team.insert([modelEventTwo])

        // Sanity check
        XCTAssert(team.events.onlyObject(eventTwo))

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // No events, including orphans, should be deleted
        XCTAssertNotNil(eventOne.managedObjectContext)
        XCTAssertNotNil(eventTwo.managedObjectContext)
    }

    func test_insert_media() {
        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)

        let modelOne = TBAMedia(type: "youtube", foreignKey: "key", details: nil, preferred: false, directURL: nil, viewURL: nil)
        let modelTwo = TBAMedia(type: "youtube", foreignKey: "key", details: nil, preferred: false, directURL: nil, viewURL: nil)
        team.insert([modelOne], year: 2010)
        team.insert([modelTwo], year: 2011)
        let mediaOne = team.media.first(where: { $0.year == 2010 })!
        let mediaTwo = team.media.first(where: { $0.year == 2011 })!

        // Sanity check
        XCTAssertNotEqual(mediaOne, mediaTwo)

        let modelThree = TBAMedia(type: "youtube", foreignKey: "new_key", details: nil, preferred: false, directURL: nil, viewURL: nil)
        team.insert([modelThree], year: 2010)
        let mediaThree = team.media.first(where: { $0.foreignKey == "new_key" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that our Team manged it's Media properly
        XCTAssertEqual(team.media.count, 2)

        // Check that our Media One was deleted (since it was an orphan)
        XCTAssertNil(mediaOne.managedObjectContext)

        // Check that Media Two and Media Three weren't deleted, since they're not orphans
        XCTAssertNotNil(mediaTwo.managedObjectContext)
        XCTAssertNotNil(mediaThree.managedObjectContext)
    }

    func test_insert_mimimum() {
        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        Team.insert(model, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelOne = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let teamOne = Team.insert(modelOne, in: persistentContainer.viewContext)

        let modelTwo = TBATeam(key: "frc7332", teamNumber: 7332, name: "New Name", rookieYear: 2011)
        let teamTwo = Team.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(teamOne, teamTwo)

        // Check our values were updated properly
        XCTAssertEqual(teamOne.name, "New Name")
        XCTAssertEqual(teamOne.rookieYear, 2011)
    }

    func test_delete() {
        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)

        let event = insertDistrictEvent()
        team.addToEventsRaw(event)

        let mediaModel = TBAMedia(type: "key", foreignKey: "youtube", details: nil, preferred: false, directURL: nil, viewURL: nil)
        let media = TeamMedia.insert(mediaModel, year: 2010, in: persistentContainer.viewContext)
        team.addToMediaRaw(media)

        persistentContainer.viewContext.delete(team)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check our Event has updated it's relationship properly
        XCTAssertFalse(event.teams.contains(team))

        // Our Event shouldn't be deleted
        XCTAssertNotNil(event.managedObjectContext)

        // Our Media should be deleted
        XCTAssertNil(media.managedObjectContext)
    }

    func test_myTBASubscribable() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.keyRaw = "frc1"

        XCTAssertEqual(team.modelKey, "frc1")
        XCTAssertEqual(team.modelType, .team)
        XCTAssertEqual(Team.notificationTypes.count, 5)
    }

    func test_avatar() {
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)

        let teamMedia = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        teamMedia.yearRaw = NSNumber(value: 2018)
        teamMedia.typeStringRaw = MediaType.avatar.rawValue

        team.addToMediaRaw(teamMedia)

        XCTAssertNil(team.avatar(year: 2019))
        XCTAssertNotNil(team.avatar(year: 2018))
    }

}
