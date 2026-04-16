import Foundation

public struct MyTBAPreferences: Codable {
    var deviceKey: String?
    var favorite: Bool
    var modelKey: String
    var modelType: MyTBAModelType
    var notifications: [NotificationType]
}

public struct MyTBAPreferencesMessageResponse: Codable {
    public let favorite: MyTBABaseResponse
    public let subscription: MyTBABaseResponse
}

extension MyTBA {

    // TODO: Android has some local rate limiting, which is probably smart
    // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/174

    public func updatePreferences(modelKey: String,
                                  modelType: MyTBAModelType,
                                  favorite: Bool,
                                  notifications: [NotificationType]) async throws -> MyTBAPreferencesMessageResponse {
        let preferences = MyTBAPreferences(deviceKey: fcmToken,
                                           favorite: favorite,
                                           modelKey: modelKey,
                                           modelType: modelType,
                                           notifications: notifications)
        let encoded = try MyTBA.jsonEncoder.encode(preferences)
        let response: MyTBABaseResponse = try await callApi(method: "model/setPreferences", bodyData: encoded)
        guard let data = response.message.data(using: .utf8) else {
            throw MyTBAError.error(nil, "Error decoding myTBA preferences response")
        }
        return try JSONDecoder().decode(MyTBAPreferencesMessageResponse.self, from: data)
    }

}
