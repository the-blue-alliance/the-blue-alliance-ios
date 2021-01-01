import Foundation

public struct MyTBARegisterRequest: Codable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    internal let operatingSystem: String = "ios"
}

extension MyTBA {

    public func register(token: String, completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        return registerUnregister("register", token: token, completion: completion)
    }

    public func unregister(token: String, completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        return registerUnregister("unregister", token: token, completion: completion)
    }

    private func registerUnregister(_ method: String, token: String, completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        let registration = MyTBARegisterRequest(deviceUuid: uuid, mobileId: token, name: deviceName)

        guard let encodedRegistration = try? MyTBA.jsonEncoder.encode(registration) else {
            return nil
        }
        return callApi(method: method, bodyData: encodedRegistration, completion: completion)
    }

}
