import CoreData
import TBAUtils
import XCTest
@testable import TBAData

class MockErrorRecorder: ErrorRecorder {

    func log(_ format: String, _ args: [CVarArg]) {
        // Pass
    }

    func record(_ error: Error) {
        // Pass
    }

}

class MockManagedObjectContext: NSManagedObjectContext {

    var saveExpectation: XCTestExpectation?
    var failSave: Bool = false

    override func save() throws {
        saveExpectation?.fulfill()
        if failSave {
            throw NSError(domain: "com.zach.zor", code: 7332, userInfo: [:])
        }
    }

}

class NSManagedObjectContextExtensionTests: TBADataTestCase {

    var errorRecorder: MockErrorRecorder!

    override func setUp() {
        super.setUp()

        errorRecorder = MockErrorRecorder()
    }

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

        managedObjectContext.performSaveOrRollback(errorRecorder: errorRecorder)
        wait(for: [saveExpectation], timeout: 1.0)
    }

    func test_performChanges() {
        let managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let saveExpectation = XCTestExpectation(description: "managedObjectContext save called")
        managedObjectContext.saveExpectation = saveExpectation

        let performExpectation = XCTestExpectation(description: "perform called")
        managedObjectContext.performChanges({
            performExpectation.fulfill()
        }, errorRecorder: errorRecorder)
        wait(for: [performExpectation, saveExpectation], timeout: 1.0)
    }

    func test_performChangesAndWait() {
        let managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let saveExpectation = XCTestExpectation(description: "managedObjectContext save called")
        managedObjectContext.saveExpectation = saveExpectation

        let performExpectation = XCTestExpectation(description: "perform called")
        let saveSuccessfulExpectation = expectation(description: "save was successful")
        managedObjectContext.performChangesAndWait({
            performExpectation.fulfill()
        }, saved: {
            saveSuccessfulExpectation.fulfill()
        }, errorRecorder: errorRecorder)

        let finalExpectation = expectation(description: "After wait executed")
        finalExpectation.fulfill()

        wait(for: [performExpectation, saveExpectation, saveSuccessfulExpectation, finalExpectation], timeout: 1.0, enforceOrder: true)
    }

    func test_performChangesAndWait_failSave() {
        let managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let saveExpectation = XCTestExpectation(description: "managedObjectContext save called")
        managedObjectContext.saveExpectation = saveExpectation
        managedObjectContext.failSave = true

        let performExpectation = XCTestExpectation(description: "perform called")
        let saveSuccessfulExpectation = expectation(description: "save was successful")
        saveSuccessfulExpectation.isInverted = true
        managedObjectContext.performChangesAndWait({
            performExpectation.fulfill()
        }, saved: {
            saveSuccessfulExpectation.fulfill()
        }, errorRecorder: errorRecorder)

        let finalExpectation = expectation(description: "After wait executed")
        finalExpectation.fulfill()

        wait(for: [performExpectation, saveExpectation, finalExpectation, saveSuccessfulExpectation], timeout: 1.0, enforceOrder: true)
    }

    func test_performChangesAndWait_noSave() {
        let managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let saveExpectation = XCTestExpectation(description: "managedObjectContext save called")
        managedObjectContext.saveExpectation = saveExpectation

        let performExpectation = XCTestExpectation(description: "perform called")
        managedObjectContext.performChangesAndWait({
            performExpectation.fulfill()
        }, errorRecorder: errorRecorder)

        let finalExpectation = expectation(description: "After wait executed")
        finalExpectation.fulfill()

        wait(for: [performExpectation, saveExpectation, finalExpectation], timeout: 1.0, enforceOrder: true)
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
