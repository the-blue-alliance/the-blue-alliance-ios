import XCTest
@testable import TBA

class MyTBAPreferencesTests: MyTBATestCase {

    func test_preferences() {
        let ex = expectation(description: "model/setPreferences called")
        let task = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
            XCTAssertNotNil(favoriteResponse)
            XCTAssertNotNil(subscriptionResponse)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task!)
        wait(for: [ex], timeout: 1.0)
    }

    func test_preferences_error() {
        let ex = expectation(description: "model/setPreferences called")
        let task = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(favoriteResponse)
            XCTAssertNil(subscriptionResponse)
            ex.fulfill()
        }
        myTBA.sendStub(for: task!, code: 401)
        wait(for: [ex], timeout: 1.0)
    }

}
