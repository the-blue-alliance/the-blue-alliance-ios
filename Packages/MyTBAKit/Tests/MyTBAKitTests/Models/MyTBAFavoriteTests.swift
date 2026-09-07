import MyTBAKit
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

    // The server signals auth failure inside a 200 body. Before the envelope
    // check this decoded as an empty list, and the app would then wipe the
    // user's cached favorites with it.
    func test_favorites_unauthorized() async {
        myTBA.stub(for: "favorites/list", code: 401)
        do {
            _ = try await myTBA.fetchFavorites()
            XCTFail("Expected a 401 to throw")
        } catch let error as MyTBAError {
            XCTAssertEqual(error.code, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

}
