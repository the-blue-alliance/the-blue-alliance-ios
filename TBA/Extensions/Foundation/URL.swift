import Foundation

private extension URL {
    func checkRemoteURLIsReachable() async throws -> Bool {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"

        let session = URLSession(configuration: .ephemeral)
        _ = try await session.data(for: request)
        return true
    }
}
