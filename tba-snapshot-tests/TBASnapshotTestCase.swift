import FBSnapshotTestCase
import Foundation

class TBASnapshotTestCase: XCTestCase {

    override func setUp() {
        super.setUp()

        agnosticOptions = .OS
        // Uncomment to record all new snapshots
        // recordMode = true
    }

    override func tearDown() {
        NotificationCenter.default.removeObserver(self)

        super.tearDown()
    }

}
