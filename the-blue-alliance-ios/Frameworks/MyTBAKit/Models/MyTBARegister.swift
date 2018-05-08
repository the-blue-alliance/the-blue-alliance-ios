import Foundation
import GTMSessionFetcher
import Firebase

struct MyTBARegisterRequest: Codable {
    
    var deviceUuid: String
    var mobileId: String
    var name: String
    let operatingSystem: String = "ios"

}

struct MyTBARegisterResponse: MyTBAResponse, Codable {

    var code: Int
    var message: String

}

extension MyTBA {
    
    func register(_ token: String, completion: @escaping (_ error: Error?) -> ()) -> GTMSessionFetcher? {
        return registerUnregister("register", token: token, completion: completion)
    }
    
    func unregister(_ token: String, completion: @escaping (_ error: Error?) -> ()) -> GTMSessionFetcher? {
        return registerUnregister("unregister", token: token, completion: completion)
    }
    
    private func registerUnregister(_ method: String, token: String, completion: @escaping (_ error: Error?) -> ()) -> GTMSessionFetcher? {
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
        
        return callApi(method: method, data: encodedRegistration, completion: { (registerResponse: MyTBARegisterResponse?, error: Error?) in
            if let registerResponse = registerResponse, registerResponse.code >= 400 {
                completion(APIError.error(registerResponse.message))
            } else {
                completion(error)
            }
        })
    }
    
}
