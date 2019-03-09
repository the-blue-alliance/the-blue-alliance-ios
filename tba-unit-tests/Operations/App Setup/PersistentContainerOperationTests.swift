import XCTest
import CoreData
@testable import TBA

class PersistentContainerOperationTests: XCTestCase {

    private var persistentContainer: PrivateMockPersistentContainer!
    private var persistentContainerOperation: MockPersistentContainerOperation!

    override func setUp() {
        super.setUp()

        persistentContainer = PrivateMockPersistentContainer(name: "Test")
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
        persistentContainer.loadPersistentStoresError = NSError(domain: "com.zor.zach", code: 2337, userInfo: nil)
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

private class PrivateMockPersistentContainer: NSPersistentContainer {

    var loadPersistentStoresError: Error?

    // MARK: - Load

    override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        block(NSPersistentStoreDescription(), loadPersistentStoresError)
    }

}
