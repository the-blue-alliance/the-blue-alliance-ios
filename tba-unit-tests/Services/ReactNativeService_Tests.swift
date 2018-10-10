import XCTest
@testable import The_Blue_Alliance

class ReactNativeMetadata_Tests: XCTestCase {

    var metadata: ReactNativeMetadata!

    override func setUp() {
        super.setUp()

        // TODO: Mock UserDefaults
        metadata = ReactNativeMetadata(userDefaults: UserDefaults.standard)
    }

    override func tearDown() {
        metadata = nil

        // Until we start mocking UserDefaults as in-memory, clear aftewards
        if let bundleID = Bundle(for: type(of: self)).bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

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
