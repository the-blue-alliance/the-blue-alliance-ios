import CoreData
import FBSnapshotTestCase
import Foundation
import XCTest
@testable import The_Blue_Alliance

class TBASnapshotTestCase: FBSnapshotTestCase {

    var coreDataTestFixture: CoreDataTestFixture!
    var persistentContainer: NSPersistentContainer {
        return coreDataTestFixture.persistentContainer
    }
    var context: NSManagedObjectContext {
        return coreDataTestFixture.persistentContainer.viewContext
    }

    override func setUp() {
        super.setUp()

        fileNameOptions = .init(arrayLiteral: .OS, .screenScale, .device)
        // Uncomment to record all new snapshots
        // recordMode = true

        coreDataTestFixture = CoreDataTestFixture()
    }

    override func tearDown() {
        coreDataTestFixture = nil

        super.tearDown()
    }

    func waitOneSecond() {
        let ex = expectation(description: "Wait one second")
        ex.isInverted = true
        wait(for: [ex], timeout: 1.0)
    }

    func verifyLayer(_ layer: CALayer, identifier: String = "") {
        FBSnapshotVerifyLayer(layer,
                              identifier: identifier,
                              suffixes: NSOrderedSet(array: [""]))
    }

    func verifyView(_ view: UIView, identifier: String = "") {
        FBSnapshotVerifyView(view,
                             identifier: identifier,
                             suffixes: NSOrderedSet(array: [""]))
    }

}
