import Foundation

public struct MyTBARegisterRequest: Codable, Sendable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    internal var operatingSystem: String = "ios"
    // The app registers with FCM by Firebase Installation ID, so `mobileId` is always a FID
    internal var mobileIdType: String = "fid"
}

extension MyTBA {

    public func register() async throws -> MyTBABaseResponse {
        return try await registerUnregister("register")
    }

    public func unregister() async throws -> MyTBABaseResponse {
        return try await registerUnregister("unregister")
    }

    private func registerUnregister(_ method: String) async throws -> MyTBABaseResponse {
        guard let fid else {
            throw MyTBAError.missingFID
        }
        let registration = MyTBARegisterRequest(deviceUuid: uuid, mobileId: fid, name: deviceName)
        let encoded = try MyTBA.jsonEncoder.encode(registration)
        return try await callApi(method: method, bodyData: encoded)
    }

}
