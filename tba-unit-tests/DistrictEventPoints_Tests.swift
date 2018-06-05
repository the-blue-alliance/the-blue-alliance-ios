import Foundation
import CoreData
import XCTest
@testable import The_Blue_Alliance

class DistrictEventPoints_Tests: CoreDataTestCase {
    
    func test_predicateForEvent() {
        let districtEventPoints = DistrictEventPoints.insert(in: managedObjectContext)
        let event = Event.insert(in: managedObjectContext)
        
        let fetchRequest: NSFetchRequest<DistrictEventPoints> = DistrictEventPoints.fetchRequest()
        fetchRequest.predicate = DistrictEventPoints.predicateForEvent(event)
        
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 0)
        
        districtEventPoints.event = event
        XCTAssertEqual(try! managedObjectContext.fetch(fetchRequest).count, 1)
    }
    
}
