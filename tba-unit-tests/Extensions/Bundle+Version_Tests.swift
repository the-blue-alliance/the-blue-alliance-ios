import XCTest
@testable import The_Blue_Alliance

class BundleVersionTestCase: XCTestCase {

    var bundle: Bundle!

    override func setUp() {
        super.setUp()

        bundle = Bundle(for: RemoteConfigTBATestCase.self)
    }

    override func tearDown() {
        bundle = nil

        super.tearDown()
    }

    func test_releaseVersionNumber() {
        XCTAssertEqual(bundle.versionString, "1.0.0")
    }

    func test_buildVersionNumber() {
        XCTAssertEqual(bundle.buildVersionNumber, 1)
    }

    func test_releaseVersionNumberPretty() {
        XCTAssertEqual(bundle.displayVersionString, "v1.0.0 (1)")
    }

}
