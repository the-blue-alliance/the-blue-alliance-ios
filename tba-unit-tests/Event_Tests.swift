import XCTest
import CoreData
@testable import The_Blue_Alliance

class Event_Tests: CoreDataTestCase {

    func test_isHappeningNow_isHappening() {
        let event = Event.insert(in: managedObjectContext)
        // Event started an hour ago, ends in an hour
        event.startDate = Date(timeIntervalSinceNow: (-1 * KDate.secondsInAnHour))
        event.endDate = Date(timeIntervalSinceNow: KDate.secondsInAnHour)
        XCTAssert(event.isHappeningNow)
    }
    
    func test_isHappeningNow_isNotHappening() {
        let event = Event.insert(in: managedObjectContext)
        // Event started 2 hours ago, ended an hour ago
        event.startDate = Date(timeIntervalSinceNow: (-2 * KDate.secondsInAnHour))
        event.endDate = Date(timeIntervalSinceNow: (-1 * KDate.secondsInAnHour))
        XCTAssertFalse(event.isHappeningNow)
    }
    
    func test_predicateForKey() {
        let testKey = "test_key"
        let event = Event.insert(in: managedObjectContext)
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForKey(testKey)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)

        event.key = testKey
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateExcludingChampionshipDivisionsForYear() {
        let year = 2015
        
        let event = Event.insert(in: managedObjectContext)
        let eventChampionshipDivision = Event.insert(in: managedObjectContext)
        eventChampionshipDivision.eventType = Int16(EventType.championshipDivision.rawValue)

        for event in [event, eventChampionshipDivision] {
            event.year = Int16(year)
        }

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateExcludingChampionshipDivisionsForYear(year)
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateExcludingChampionshipDivisionsForYear_beforeEndDate() {
        let year = 2015
        let oneHourFromNow = Date(timeIntervalSinceNow: KDate.secondsInAnHour)

        let event = Event.insert(in: managedObjectContext)
        event.endDate = oneHourFromNow
        let finishedEvent = Event.insert(in: managedObjectContext)
        finishedEvent.endDate = Date(timeIntervalSince1970: 0)
        let eventChampionshipDivision = Event.insert(in: managedObjectContext)
        eventChampionshipDivision.eventType = Int16(EventType.championshipDivision.rawValue)
        eventChampionshipDivision.endDate = oneHourFromNow
        
        for event in [event, finishedEvent, eventChampionshipDivision] {
            event.year = Int16(year)
        }

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateExcludingChampionshipDivisionsForYear(year, beforeEndDate: NSDate())
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateForYear() {
        let year = 2015

        let event = Event.insert(in: managedObjectContext)
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForYear(year)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)

        event.year = Int16(year)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateForWeek_andYear() {
        let week = 1
        let year = 2015

        let weekOneEvent = Event.insert(in: managedObjectContext)
        weekOneEvent.week = NSNumber(value: week)
        let weekTwoEvent = Event.insert(in: managedObjectContext)
        weekTwoEvent.week = NSNumber(value: week + 1)

        for event in [weekOneEvent, weekTwoEvent] {
            event.year = Int16(year)
        }

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForWeek(week, andYear: year)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateForEventType_andYear() {
        let year = 2015
        
        let districtEvent = Event.insert(in: managedObjectContext)
        districtEvent.eventType = Int16(EventType.district.rawValue)
        let regionalEvent = Event.insert(in: managedObjectContext)
        regionalEvent.eventType = Int16(EventType.regional.rawValue)
        
        for event in [districtEvent, regionalEvent] {
            event.year = Int16(year)
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForEventType(EventType.district.rawValue, andYear: year)
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateForTeams_andYear() {
        let year = 2015
        let team = Team.insert(in: managedObjectContext)

        let event = Event.insert(in: managedObjectContext)
        event.year = Int16(year)

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForTeams(withTeam: team, andYear: year)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)

        event.addToTeams(team)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_predicateForDistrict() {
        let district = District.insert(in: managedObjectContext)
        
        let event = Event.insert(in: managedObjectContext)
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForDistrict(district)
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)
        
        event.district = district
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
    func test_nullYearPredicate() {
        let event = Event.insert(in: managedObjectContext)

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForNoResults()
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)

        event.year = Int16(2015)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)
    }

    func test_predicateForChampionshipEventsForWeek_oneChampionship() {
        let year = 2015
        let parentKey = "\(year)cmp"

        let championshipFinal = Event.insert(in: managedObjectContext)
        championshipFinal.key = parentKey
        championshipFinal.eventType = Int16(EventType.championshipFinals.rawValue)
        
        let championshipDivision = Event.insert(in: managedObjectContext)
        championshipDivision.parentEventKey = parentKey
        championshipDivision.eventType = Int16(EventType.championshipDivision.rawValue)
        
        for event in [championshipDivision, championshipFinal] {
            event.year = Int16(year)
        }

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForChampionshipEventsWithParentKey(parentKey, andYear: year)
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 2)
    }

    func test_predicateForChampionshipEventsForWeek_twoChampionships() {
        let year = 2018
        let cmpLocations = ["mi", "tx"]
        
        for location in cmpLocations {
            let parentKey = "\(year)cmp\(location)"

            let championshipFinal = Event.insert(in: managedObjectContext)
            championshipFinal.key = parentKey
            championshipFinal.eventType = Int16(EventType.championshipFinals.rawValue)
            
            let championshipDivision = Event.insert(in: managedObjectContext)
            championshipDivision.parentEventKey = parentKey
            championshipDivision.eventType = Int16(EventType.championshipDivision.rawValue)
            
            for event in [championshipDivision, championshipFinal] {
                event.year = Int16(year)
            }
        }

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = Event.predicateForChampionshipEventsWithParentKey("\(year)cmp\(cmpLocations.first!)", andYear: year)
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 2)
    }

}
