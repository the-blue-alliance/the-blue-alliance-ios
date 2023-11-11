import MyTBAKit
import XCTest

class MyTBAPreferencesTests: MyTBATestCase {

    func test_preferences() {
        let ex = expectation(description: "model/setPreferences called")
        let operation = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
            XCTAssertNotNil(favoriteResponse)
            XCTAssertNotNil(subscriptionResponse)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation!)
        wait(for: [ex], timeout: 1.0)
    }

    func test_preferences_error() {
        let ex = expectation(description: "model/setPreferences called")
        let operation = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(favoriteResponse)
            XCTAssertNil(subscriptionResponse)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation!, code: 401)
        wait(for: [ex], timeout: 1.0)
    }

}
