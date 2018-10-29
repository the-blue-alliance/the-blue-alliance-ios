import TBAKit
import XCTest
@testable import The_Blue_Alliance

class TeamTestCase: CoreDataTestCase {

    func test_insert() {
        let model = TBATeam(key: "frc7332",
                            teamNumber: 7332,
                            nickname: "The Rawrbotz",
                            name: "The first ever FRC team sponsored by small donors",
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
                            motto: "Some motto",
                            homeChampionship: ["2018": "Detroit"])
        let team = Team.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(team.key, "frc7332")
        XCTAssertEqual(team.teamNumber, 7332)
        XCTAssertEqual(team.nickname, "The Rawrbotz")
        XCTAssertEqual(team.name, "The first ever FRC team sponsored by small donors")
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
        XCTAssertEqual(team.motto, "Some motto")
        XCTAssertEqual(team.homeChampionship, ["2018": "Detroit"])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_events() {
        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let modelEventOne = TBAEvent(key: "2018miket", name: "Event 1", eventCode: "miket", eventType: 1, startDate: dateFormatter.date(from: "2018-03-01")!, endDate: dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])
        let modelEventTwo = TBAEvent(key: "2018mike2", name: "Event 2", eventCode: "mike2", eventType: 1, startDate: dateFormatter.date(from: "2018-03-01")!, endDate: dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])

        team.insert([modelEventOne, modelEventTwo])

        let events = team.events!.allObjects as! [Event]
        let eventOne = events.first(where: { $0.key == "2018miket" })!
        let eventTwo = events.first(where: { $0.key == "2018mike2" })!

        // Sanity check
        XCTAssertEqual(team.events?.count, 2)
        XCTAssertNotEqual(eventOne, eventTwo)

        team.insert([modelEventTwo])

        // Sanity check
        XCTAssert(team.events!.onlyObject(eventTwo))

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // No events, including orphans, should be deleted
        XCTAssertNotNil(eventOne.managedObjectContext)
        XCTAssertNotNil(eventTwo.managedObjectContext)
    }

    func test_insert_media() {
        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)

        let modelOne = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        let modelTwo = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        team.insert([modelOne], year: 2010)
        team.insert([modelTwo], year: 2011)
        let mediaOne = (team.media!.allObjects as! [TeamMedia]).first(where: { $0.year == 2010 })!
        let mediaTwo = (team.media!.allObjects as! [TeamMedia]).first(where: { $0.year == 2011 })!

        // Sanity check
        XCTAssertNotEqual(mediaOne, mediaTwo)

        let modelThree = TBAMedia(key: "new_key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        team.insert([modelThree], year: 2010)
        let mediaThree = (team.media!.allObjects as! [TeamMedia]).first(where: { $0.key == "new_key" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that our Team manged it's Media properly
        XCTAssertEqual(team.media?.count, 2)

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

        let event = districtEvent()
        team.addToEvents(event)

        let mediaModel = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: nil)
        let media = TeamMedia.insert(mediaModel, year: 2010, in: persistentContainer.viewContext)
        team.addToMedia(media)

        persistentContainer.viewContext.delete(team)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check our Event has updated it's relationship properly
        XCTAssertFalse(event.teams!.contains(team))

        // Our Event shouldn't be deleted
        XCTAssertNotNil(event.managedObjectContext)

        // Our Media should be deleted
        XCTAssertNil(media.managedObjectContext)
    }

}
