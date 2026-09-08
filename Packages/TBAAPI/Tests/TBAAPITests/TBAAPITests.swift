import Testing
@testable import TBAAPI

struct TBAAPITests {

    @Test func setCachePolicyReplacesClient() async {
        let api = TBAAPI(apiKey: "key", cachePolicy: .default)
        #expect(await api.cachePolicy == .default)

        await api.setCachePolicy(.bypass)
        #expect(await api.cachePolicy == .bypass)
    }

}
