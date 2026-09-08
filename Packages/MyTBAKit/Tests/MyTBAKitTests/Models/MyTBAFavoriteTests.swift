import Testing

@testable import MyTBAKit

@MainActor
struct MyTBAFavoriteTests {

    let myTBA = MockMyTBA()

    @Test func favorites() async throws {
        try myTBA.stub(for: "favorites/list")
        let favorites = try await myTBA.fetchFavorites()
        #expect(favorites.count == 3)
    }

    @Test func favoritesEmpty() async throws {
        try myTBA.stub(for: "favorites/list", code: 201)
        let favorites = try await myTBA.fetchFavorites()
        #expect(favorites.isEmpty)
    }

    // The server signals auth failure inside a 200 body. Before the envelope
    // check this decoded as an empty list, and the app would then wipe the
    // user's cached favorites with it.
    @Test func favoritesUnauthorized() async throws {
        try myTBA.stub(for: "favorites/list", code: 401)
        let error = await #expect(throws: MyTBAError.self) {
            try await myTBA.fetchFavorites()
        }
        #expect(error?.code == 401)
    }

}
