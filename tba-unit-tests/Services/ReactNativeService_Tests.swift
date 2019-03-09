import XCTest
@testable import TBA

class ReactNativeMetadata_Tests: TBATestCase {

    var metadata: ReactNativeMetadata!

    override func setUp() {
        super.setUp()

        metadata = ReactNativeMetadata(userDefaults: userDefaults)
    }

    override func tearDown() {
        metadata = nil

        super.tearDown()
    }

    func test_bundleGeneration() {
        let metadataVersion = 7332
        metadata.bundleGeneration = metadataVersion
        XCTAssertEqual(metadataVersion, metadata.bundleGeneration)
    }

    func test_bundleCreated() {
        let bundleCreated = Date()
        metadata.bundleCreated = bundleCreated
        XCTAssertEqual(bundleCreated, metadata.bundleCreated)
    }

    func test_metadataProvider() {
        let metadataUpdatedExpectation = XCTestExpectation(description: "metadataUpdated called")

        let provider = MockMetadataProvider()
        provider.metadataUpdatedExpectation = metadataUpdatedExpectation

        metadata.metadataProvider.add(observer: provider)
        metadata.bundleGeneration = 7332

        wait(for: [metadataUpdatedExpectation], timeout: 1.0)
    }

}

class MockMetadataProvider: ReactNativeMetadataObservable {

    var metadataUpdatedExpectation: XCTestExpectation?

    func metadataUpdated() {
        metadataUpdatedExpectation?.fulfill()
    }


}
