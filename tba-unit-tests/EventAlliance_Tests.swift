import Foundation
import CoreData
import XCTest
@testable import The_Blue_Alliance

class EventAlliance_Tests: CoreDataTestCase {
    
    func test_predicateForEvent() {
        let eventAlliance = EventAlliance.insert(in: managedObjectContext)
        let event = Event.insert(in: managedObjectContext)
        
        let fetchRequest: NSFetchRequest<EventAlliance> = EventAlliance.fetchRequest()
        fetchRequest.predicate = EventAlliance.predicateForEvent(event: event)

        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)
        
        eventAlliance.event = event
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
}
