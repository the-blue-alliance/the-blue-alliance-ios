import Foundation

struct MyTBAPingRequest: Codable {
    var mobileId: String
}

extension MyTBA {

    public func ping(completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        guard let token = fcmToken else {
            return nil
        }
        let ping = MyTBAPingRequest(mobileId: token)

        guard let encodedPing = try? MyTBA.jsonEncoder.encode(ping) else {
            return nil
        }
        return callApi(method: "ping", bodyData: encodedPing, completion: completion)
    }

}
