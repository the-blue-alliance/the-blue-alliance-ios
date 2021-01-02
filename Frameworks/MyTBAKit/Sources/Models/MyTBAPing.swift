import Foundation

struct MyTBAPingRequest: Codable {
    var mobileId: String
}

extension MyTBA {

    public func ping(token: String, completion: @escaping MyTBABaseCompletionBlock) -> MyTBAOperation? {
        let ping = MyTBAPingRequest(mobileId: token)

        guard let encodedPing = try? MyTBA.jsonEncoder.encode(ping) else {
            return nil
        }
        return callApi(method: "ping", bodyData: encodedPing, completion: completion)
    }

}
