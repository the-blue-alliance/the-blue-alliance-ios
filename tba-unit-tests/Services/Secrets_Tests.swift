import XCTest
@testable import The_Blue_Alliance

class Secrets_Tests: XCTestCase {

    func test_loadSecrets() {
        let secrets = Secrets(secrets: "TestSecrets", in: Bundle(for: Secrets_Tests.self))
        XCTAssertNotNil(secrets)
    }

    func test_TBAAPIKey() {
        let secrets = Secrets(secrets: "TestSecrets", in: Bundle(for: Secrets_Tests.self))
        XCTAssertNotNil(secrets.tbaAPIKey)
        XCTAssertEqual(secrets.tbaAPIKey, "abcd1234")
    }

}
