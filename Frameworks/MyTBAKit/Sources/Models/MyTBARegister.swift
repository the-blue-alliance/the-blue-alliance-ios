import Foundation

public struct MyTBARegisterRequest: Codable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    internal let operatingSystem: String = "ios"
}

extension MyTBA {

    @discardableResult
    public func register(_ token: String, completion: @escaping MyTBABaseCompletionBlock) -> URLSessionDataTask? {
        return registerUnregister("register", token: token, completion: completion)
    }

    @discardableResult
    public func unregister(_ token: String, completion: @escaping MyTBABaseCompletionBlock) -> URLSessionDataTask? {
        return registerUnregister("unregister", token: token, completion: completion)
    }

    private func registerUnregister(_ method: String, token: String, completion: @escaping MyTBABaseCompletionBlock) -> URLSessionDataTask? {
        let registration = MyTBARegisterRequest(deviceUuid: uuid, mobileId: token, name: deviceName)

        guard let encodedRegistration = try? MyTBA.jsonEncoder.encode(registration) else {
            completion(nil, MyTBAError.error("Unable to update myTBA registration - invalid data"))
            return nil
        }
        return callApi(method: method, bodyData: encodedRegistration, completion: completion)
    }

}
