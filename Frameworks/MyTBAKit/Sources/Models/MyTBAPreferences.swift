import Foundation

public struct MyTBAPreferences: Codable {
    var deviceKey: String
    var favorite: Bool
    var modelKey: String
    var modelType: MyTBAModelType
    var notifications: [NotificationType]
}

public struct MyTBAPreferencesMessageResponse: Codable {
    let favorite: MyTBABaseResponse
    let subscription: MyTBABaseResponse
}

extension MyTBA {

    // TODO: Android has some local rate limiting, which is probably smart
    // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/174

    @discardableResult
    public func updatePreferences(modelKey: String, modelType: MyTBAModelType, favorite: Bool, notifications: [NotificationType], completion: @escaping (_ favoriteResponse: MyTBABaseResponse?, _ subscriptionResponse: MyTBABaseResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let preferences = MyTBAPreferences(deviceKey: uuid,
                                           favorite: favorite,
                                           modelKey: modelKey,
                                           modelType: modelType,
                                           notifications: notifications)

        guard let encodedPreferences = try? MyTBA.jsonEncoder.encode(preferences) else {
            completion(nil, nil, MyTBAError.error("Unable to update myTBA preferences - invalid data"))
            return nil
        }

        let method = "model/setPreferences"

        return callApi(method: method, bodyData: encodedPreferences, completion: { (preferencesResponse: MyTBABaseResponse?, error: Error?) in
            if let preferencesResponse = preferencesResponse, let data = preferencesResponse.message.data(using: .utf8) {
                guard let messageResponse = try? JSONDecoder().decode(MyTBAPreferencesMessageResponse.self, from: data) else {
                    completion(nil, nil, MyTBAError.error("Error decoding myTBA preferences response"))
                    return
                }
                completion(messageResponse.favorite, messageResponse.subscription, error)
            } else {
                completion(nil, nil, error)
            }
        })
    }

}
