import Foundation
import Firebase

struct MyTBARegisterRequest: Codable {

    var deviceUuid: String
    var mobileId: String
    var name: String
    let operatingSystem: String = "ios"

}

struct MyTBARegisterResponse: MyTBAResponse, Codable {

    var code: String // TODO: File a bug with web - this code needs to be an Int
    var message: String

}

extension MyTBA {

    @discardableResult
    func register(_ token: String, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return registerUnregister("register", token: token, completion: completion)
    }

    @discardableResult
    @objc func unregister(_ token: String, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return registerUnregister("unregister", token: token, completion: completion)
    }

    private func registerUnregister(_ method: String, token: String, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            completion(APIError.error("Unable to update myTBA registration - no UUID"))
            return nil
        }

        let registration = MyTBARegisterRequest(deviceUuid: uuid,
                                                mobileId: token,
                                                name: UIDevice.current.name)

        guard let encodedRegistration = try? MyTBA.jsonEncoder.encode(registration) else {
            completion(APIError.error("Unable to update myTBA registration - invalid data"))
            return nil
        }

        return callApi(method: method, bodyData: encodedRegistration, completion: { (registerResponse: MyTBARegisterResponse?, error: Error?) in
            if let registerResponse = registerResponse, let code = Int(registerResponse.code), code >= 400 {
                completion(APIError.error(registerResponse.message))
            } else {
                completion(error)
            }
        })
    }

}
