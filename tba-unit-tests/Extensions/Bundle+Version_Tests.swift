import XCTest
@testable import The_Blue_Alliance

class MockBundle: Bundle {

    override var infoDictionary: [String : Any]? {
        return [
            "CFBundleShortVersionString": "2.3.1",
            "CFBundleVersion": "22"
        ]
    }

}

class BundleVersionTestCase: XCTestCase {

    var bundle: Bundle!

    override func setUp() {
        super.setUp()

        bundle = MockBundle()
    }

    override func tearDown() {
        bundle = nil

        super.tearDown()
    }

    func test_releaseVersionNumber() {
        XCTAssertEqual(bundle.versionString, "2.3.1")
    }

    func test_buildVersionNumber() {
        XCTAssertEqual(bundle.buildVersionNumber, 22)
    }

    func test_releaseVersionNumberPretty() {
        XCTAssertEqual(bundle.displayVersionString, "v2.3.1 (22)")
    }

}
