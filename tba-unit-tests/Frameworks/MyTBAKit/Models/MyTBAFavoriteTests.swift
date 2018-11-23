import XCTest
@testable import The_Blue_Alliance

class MyTBAFavoriteTests: MyTBATestCase {

    func test_subscriptions() {
        let ex = expectation(description: "favorites/list called")
        let task = myTBA.fetchFavorites { (favorites, error) in
            XCTAssertNotNil(favorites)
            XCTAssertEqual(favorites?.count, 5)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task)
        wait(for: [ex], timeout: 1.0)
    }

}
