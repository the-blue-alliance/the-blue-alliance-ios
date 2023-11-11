import Foundation

public struct MyTBARegisterRequest: Codable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    internal var operatingSystem: String = "ios"
}

extension MyTBA {

    public func register(completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        return registerUnregister("register", completion: completion)
    }

    public func unregister(completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        return registerUnregister("unregister", completion: completion)
    }

    private func registerUnregister(_ method: String, completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        guard let token = fcmToken else {
            return nil
        }
        let registration = MyTBARegisterRequest(deviceUuid: uuid, mobileId: token, name: deviceName)

        guard let encodedRegistration = try? MyTBA.jsonEncoder.encode(registration) else {
            return nil
        }
        return callApi(method: method, bodyData: encodedRegistration, completion: completion)
    }

}
