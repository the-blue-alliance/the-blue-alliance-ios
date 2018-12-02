import Foundation
import Firebase

struct MyTBARegisterRequest: Codable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    let operatingSystem: String = "ios"
}

extension MyTBA {

    @discardableResult
    func register(_ token: String, completion: @escaping MyTBABaseCompletionBlock) -> URLSessionDataTask? {
        return registerUnregister("register", token: token, completion: completion)
    }

    @discardableResult
    func unregister(_ token: String, completion: @escaping MyTBABaseCompletionBlock) -> URLSessionDataTask? {
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
