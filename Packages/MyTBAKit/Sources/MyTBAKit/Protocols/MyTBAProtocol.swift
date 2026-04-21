import Foundation

public protocol MyTBAProtocol: AnyObject, Sendable {
    nonisolated var isAuthenticated: Bool { get }

    func authStateChanges() async -> AsyncStream<Bool>
    func notifyAuthStateChanged(isAuthenticated: Bool) async

    func ping() async throws -> MyTBABaseResponse
    func register() async throws -> MyTBABaseResponse
    func unregister() async throws -> MyTBABaseResponse
    func fetchFavorites() async throws -> [MyTBAFavorite]
    func fetchSubscriptions() async throws -> [MyTBASubscription]
    func updatePreferences(
        modelKey: String,
        modelType: MyTBAModelType,
        favorite: Bool,
        notifications: [NotificationType]
    ) async throws -> MyTBAPreferencesMessageResponse
}

extension MyTBA: MyTBAProtocol {}
