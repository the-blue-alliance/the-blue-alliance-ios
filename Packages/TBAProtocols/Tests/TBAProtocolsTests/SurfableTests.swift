import TBAProtocols
import XCTest

private class MockSurfable: Surfable {
    var website: String?
}

class SurfableTests: XCTestCase {

    func test_surfable() {
        let surfable = MockSurfable()
        surfable.website = "abc"
        XCTAssert(surfable.hasWebsite)

        let notSurfable = MockSurfable()
        XCTAssertFalse(notSurfable.hasWebsite)
    }

}
