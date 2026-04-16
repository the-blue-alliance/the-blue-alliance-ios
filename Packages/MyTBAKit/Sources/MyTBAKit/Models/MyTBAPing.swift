import Foundation

struct MyTBAPingRequest: Codable {
    var mobileId: String
}

extension MyTBA {

    public func ping() async throws -> MyTBABaseResponse {
        guard let token = fcmToken else {
            throw MyTBAError.error(nil, "Missing FCM token")
        }
        let encoded = try MyTBA.jsonEncoder.encode(MyTBAPingRequest(mobileId: token))
        return try await callApi(method: "ping", bodyData: encoded)
    }

}
