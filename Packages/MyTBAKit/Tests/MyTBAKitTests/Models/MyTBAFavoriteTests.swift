import XCTest

class MyTBAFavoriteTests: MyTBATestCase {

    func test_favorites() {
        let ex = expectation(description: "favorites/list called")
        let operation = myTBA.fetchFavorites { (favorites, error) in
            XCTAssertNotNil(favorites)
            XCTAssertEqual(favorites?.count, 3)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation)
        wait(for: [ex], timeout: 1.0)
    }

    func test_favorites_empty() {
        let ex = expectation(description: "favorites/list called")
        let operation = myTBA.fetchFavorites { (favorites, error) in
            XCTAssertNil(favorites)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation, code: 201)
        wait(for: [ex], timeout: 1.0)
    }

}
