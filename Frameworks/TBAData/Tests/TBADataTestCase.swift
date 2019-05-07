import CoreData
import TBADataTesting
import XCTest

class TBADataTestCase: XCTestCase {

    var coreDataTestFixture: CoreDataTestFixture!
    var viewContext: NSManagedObjectContext {
        return coreDataTestFixture.persistentContainer.viewContext
    }

    override func setUp() {
        super.setUp()

        coreDataTestFixture = CoreDataTestFixture()
    }

    override func tearDown() {
        coreDataTestFixture = nil

        super.tearDown()
    }

    func test_nothing() {
        // pass
    }

}
