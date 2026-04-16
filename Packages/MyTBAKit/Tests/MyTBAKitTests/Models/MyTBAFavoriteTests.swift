import XCTest

class MyTBAFavoriteTests: MyTBATestCase {

    func test_favorites() async throws {
        myTBA.stub(for: "favorites/list")
        let favorites = try await myTBA.fetchFavorites()
        XCTAssertEqual(favorites.count, 3)
    }

    func test_favorites_empty() async throws {
        myTBA.stub(for: "favorites/list", code: 201)
        let favorites = try await myTBA.fetchFavorites()
        XCTAssertTrue(favorites.isEmpty)
    }

}
