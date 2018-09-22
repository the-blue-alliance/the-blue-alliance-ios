import XCTest
import CoreData
@testable import The_Blue_Alliance

class MockManagedObjectContext: NSManagedObjectContext {

    var saveExpectation: XCTestExpectation?

    override func save() throws {
        saveExpectation?.fulfill()
    }

}

class NSManagedObjectContextExtensionTestCase: CoreDataTestCase {

    func test_insertObject() {
        let managedObjectContext = persistentContainer.viewContext
        XCTAssert(Event.fetch(in: managedObjectContext).isEmpty)

        let event: Event = managedObjectContext.insertObject()
        XCTAssertFalse(Event.fetch(in: managedObjectContext).isEmpty)

        addTeardownBlock {
            managedObjectContext.delete(event)
        }
    }

    func test_saveContext() {
        let managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let saveExpectation = XCTestExpectation(description: "managedObjectContext save called")
        managedObjectContext.saveExpectation = saveExpectation

        managedObjectContext.saveContext()
        wait(for: [saveExpectation], timeout: 1.0)
    }

    func test_performChanges() {
        let managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let saveExpectation = XCTestExpectation(description: "managedObjectContext save called")
        managedObjectContext.saveExpectation = saveExpectation

        let performExpectation = XCTestExpectation(description: "perform called")
        managedObjectContext.performChanges {
            performExpectation.fulfill()
        }
        wait(for: [performExpectation, saveExpectation], timeout: 1.0)
    }

    func test_deleteAllObjects() {
        let managedObjectContext = persistentContainer.viewContext

        // Insert one object each from two different entities (Event and Team)
        let _: Event = managedObjectContext.insertObject()
        XCTAssertFalse(Event.fetch(in: managedObjectContext).isEmpty)
        let _: Team = managedObjectContext.insertObject()
        XCTAssertFalse(Team.fetch(in: managedObjectContext).isEmpty)

        // Delete all objects
        managedObjectContext.deleteAllObjects()

        XCTAssert(Event.fetch(in: managedObjectContext).isEmpty)
        XCTAssert(Team.fetch(in: managedObjectContext).isEmpty)
    }

    func test_deleteAllObjectsForEntity() {
        let managedObjectContext = persistentContainer.viewContext

        // Insert a single object for an entity
        let _: Event = managedObjectContext.insertObject()
        XCTAssertFalse(Event.fetch(in: managedObjectContext).isEmpty)

        managedObjectContext.deleteAllObjectsForEntity(entity: Event.entity())

        XCTAssert(Event.fetch(in: managedObjectContext).isEmpty)
    }

}
