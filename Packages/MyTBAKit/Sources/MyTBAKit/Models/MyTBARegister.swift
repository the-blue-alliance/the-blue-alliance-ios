import Foundation

public struct MyTBARegisterRequest: Codable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    internal var operatingSystem: String = "ios"
}

extension MyTBA {

    public func register() async throws -> MyTBABaseResponse {
        return try await registerUnregister("register")
    }

    public func unregister() async throws -> MyTBABaseResponse {
        return try await registerUnregister("unregister")
    }

    private func registerUnregister(_ method: String) async throws -> MyTBABaseResponse {
        guard let token = fcmToken else {
            throw MyTBAError.error(nil, "Missing FCM token")
        }
        let registration = MyTBARegisterRequest(deviceUuid: uuid, mobileId: token, name: deviceName)
        let encoded = try MyTBA.jsonEncoder.encode(registration)
        return try await callApi(method: method, bodyData: encoded)
    }

}
