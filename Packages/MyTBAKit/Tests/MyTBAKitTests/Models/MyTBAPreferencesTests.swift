import MyTBAKit
import XCTest

class MyTBAPreferencesTests: MyTBATestCase {

    func test_preferences() async throws {
        myTBA.stub(for: "model/setPreferences")
        let response = try await myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: [])
        XCTAssertNotNil(response.favorite)
        XCTAssertNotNil(response.subscription)
    }

    func test_preferences_error() async {
        myTBA.stub(for: "model/setPreferences", code: 401)
        do {
            _ = try await myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: [])
            XCTFail("Expected updatePreferences to throw on 401")
        } catch {
            // expected
        }
    }

}
