import Foundation

struct MyTBAPingRequest: Codable {
    var mobileId: String
}

extension MyTBA {

    public func ping() async throws -> MyTBABaseResponse {
        guard let fid else {
            throw MyTBAError.missingFID
        }
        let encoded = try MyTBA.jsonEncoder.encode(MyTBAPingRequest(mobileId: fid))
        return try await callApi(method: "ping", bodyData: encoded)
    }

}
