import XCTest
import CoreData
@testable import The_Blue_Alliance

class PersistentContainerOperationTestCase: XCTestCase {

    var persistentContainer: MockPersistentContainer!
    var persistentContainerOperation: MockPersistentContainerOperation!

    override func setUp() {
        super.setUp()

        persistentContainer = MockPersistentContainer(name: "Test")
        persistentContainerOperation = MockPersistentContainerOperation(persistentContainer: persistentContainer)
    }

    override func tearDown() {
        persistentContainer = nil
        persistentContainerOperation = nil

        super.tearDown()
    }

    func test_execute() {
        let expectation = XCTestExpectation(description: "Finish called")
        persistentContainerOperation.finishExpectation = expectation

        persistentContainerOperation.execute()
        XCTAssert(persistentContainerOperation.persistentContainer.viewContext.automaticallyMergesChangesFromParent)
        XCTAssertNil(persistentContainerOperation.completionError)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_error() {
        persistentContainer.mockError = NSError(domain: "com.zor.zach", code: 2337, userInfo: nil)
        persistentContainerOperation.execute()
        XCTAssertNotNil(persistentContainerOperation.completionError)
    }

}

class MockPersistentContainerOperation: PersistentContainerOperation {

    var finishExpectation: XCTestExpectation?

    override func finish() {
        super.finish()

        finishExpectation?.fulfill()
    }

}

class MockPersistentContainer: NSPersistentContainer {

    var mockError: Error?

    override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        block(NSPersistentStoreDescription(), mockError)
    }

}
