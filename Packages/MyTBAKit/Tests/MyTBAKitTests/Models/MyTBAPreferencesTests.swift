import Testing

@testable import MyTBAKit

@MainActor
struct MyTBAPreferencesTests {

    let myTBA = MockMyTBA()

    @Test func preferences() async throws {
        try myTBA.stub(for: "model/setPreferences")
        let response = try await myTBA.updatePreferences(
            modelKey: "2018ckw0",
            modelType: .event,
            favorite: true,
            notifications: []
        )
        #expect(response.favorite.code == 200)
        #expect(response.subscription.code == 200)
    }

    @Test func preferencesUnauthorized() async throws {
        try myTBA.stub(for: "model/setPreferences", code: 401)
        let error = await #expect(throws: MyTBAError.self) {
            try await myTBA.updatePreferences(
                modelKey: "2018ckw0",
                modelType: .event,
                favorite: true,
                notifications: []
            )
        }
        #expect(error?.code == 401)
    }

}
