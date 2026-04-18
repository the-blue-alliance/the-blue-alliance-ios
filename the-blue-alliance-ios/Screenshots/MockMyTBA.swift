#if SCREENSHOT_MODE
import Foundation
import MyTBAKit
import TBAUtils

private enum MockMyTBAError: Error {
    case notImplemented
}

final class MockMyTBA: MyTBAProtocol {

    var authToken: String? = "mock-token"
    var isAuthenticated: Bool { true }
    let authenticationProvider = Provider<MyTBAAuthenticationObservable>()

    private static func decode<T: Decodable>(_ type: T.Type, json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    func ping() async throws -> MyTBABaseResponse {
        try Self.decode(MyTBABaseResponse.self, json: #"{"code":200,"message":"ok"}"#)
    }

    func register() async throws -> MyTBABaseResponse {
        try Self.decode(MyTBABaseResponse.self, json: #"{"code":200,"message":"ok"}"#)
    }

    func unregister() async throws -> MyTBABaseResponse {
        try Self.decode(MyTBABaseResponse.self, json: #"{"code":200,"message":"ok"}"#)
    }

    func fetchFavorites() async throws -> [MyTBAFavorite] { [] }

    func fetchSubscriptions() async throws -> [MyTBASubscription] { [] }

    func updatePreferences(modelKey: String,
                           modelType: MyTBAModelType,
                           favorite: Bool,
                           notifications: [NotificationType]) async throws -> MyTBAPreferencesMessageResponse {
        throw MockMyTBAError.notImplemented
    }
}
#endif
