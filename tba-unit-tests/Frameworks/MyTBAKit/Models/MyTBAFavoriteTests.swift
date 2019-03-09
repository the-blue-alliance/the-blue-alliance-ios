import XCTest
@testable import TBA

class MyTBAFavoriteTests: MyTBATestCase {

    func test_favorites() {
        let ex = expectation(description: "favorites/list called")
        let task = myTBA.fetchFavorites { (favorites, error) in
            XCTAssertNotNil(favorites)
            XCTAssertEqual(favorites?.count, 3)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task)
        wait(for: [ex], timeout: 1.0)
    }

    func test_favorites_empty() {
        let ex = expectation(description: "favorites/list called")
        let task = myTBA.fetchFavorites { (favorites, error) in
            XCTAssertNil(favorites)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task, code: 201)
        wait(for: [ex], timeout: 1.0)
    }

}
