import Foundation
import TBAUtils

public protocol MyTBAProtocol: AnyObject {
    var authToken: String? { get set }
    var isAuthenticated: Bool { get }
    var authenticationProvider: Provider<MyTBAAuthenticationObservable> { get }

    func ping() async throws -> MyTBABaseResponse
    func register() async throws -> MyTBABaseResponse
    func unregister() async throws -> MyTBABaseResponse
    func fetchFavorites() async throws -> [MyTBAFavorite]
    func fetchSubscriptions() async throws -> [MyTBASubscription]
    func updatePreferences(modelKey: String,
                           modelType: MyTBAModelType,
                           favorite: Bool,
                           notifications: [NotificationType]) async throws -> MyTBAPreferencesMessageResponse
}

extension MyTBA: MyTBAProtocol {}
