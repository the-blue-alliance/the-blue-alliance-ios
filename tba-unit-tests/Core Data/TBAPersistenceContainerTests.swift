import XCTest
import CoreData
@testable import The_Blue_Alliance

class TBAPersistenceContainerTests: XCTest {

    func test_init() {
        let persistenceContainer = TBAPersistenceContainer()
        XCTAssertEqual(persistenceContainer.name, "TBA")
    }

    func test_backgroundContext() {
        let persistenceContainer = TBAPersistenceContainer()
        let context = persistenceContainer.newBackgroundContext()

        let mergePolicy = context.mergePolicy as! NSMergePolicy
        XCTAssertEqual(mergePolicy.mergeType, .mergeByPropertyObjectTrumpMergePolicyType)
    }

}
