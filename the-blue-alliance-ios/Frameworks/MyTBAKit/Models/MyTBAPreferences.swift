import Foundation

struct MyTBAPreferences: Codable {

    var deviceKey: String
    var favorite: Bool
    var modelKey: String
    var modelType: MyTBAModelType
    var notifications: [NotificationType]

}


struct MyTBAPreferencesResponse: MyTBAResponse, Codable {
    var code: Int
    var message: String
}

struct MyTBAPreferencesMessageResponse: Codable {
    let favorite: MyTBAPreferencesSubResponse
    let subscription: MyTBAPreferencesSubResponse
}

// Responses for favorite/subscription actions stored in MyPreferencesResponse.message
struct MyTBAPreferencesSubResponse: Codable {
    var code: Int
    var message: String
}

extension MyTBA {

    // TODO: Android has some local rate limiting, which is probably smart
    // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/174

    @discardableResult
    func updatePreferences(modelKey: String, modelType: MyTBAModelType, favorite: Bool, notifications: [NotificationType], completion: @escaping (_ favoriteResponse: MyTBAPreferencesSubResponse?, _ subscriptionResponse: MyTBAPreferencesSubResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
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
        return callApi(method: method, bodyData: encodedPreferences, completion: { (preferencesResponse: MyTBAPreferencesResponse?, error: Error?) in
            if let preferencesResponse = preferencesResponse, let data = preferencesResponse.message.data(using: .utf8) {
                let messageResponse = try! JSONDecoder().decode(MyTBAPreferencesMessageResponse.self, from: data)
                completion(messageResponse.favorite, messageResponse.subscription, error)
            } else {
                completion(nil, nil, error)
            }
        })
    }
}
