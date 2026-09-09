import Foundation
import MyTBAKit
import TBAAuth
import TBAUtils
import UIKit

@testable import The_Blue_Alliance

/// Ordered record of calls across mocks, so tests can assert sequencing.
final class CallLog {
    private(set) var entries: [String] = []

    func append(_ entry: String) {
        entries.append(entry)
    }
}

enum MockError: Error, Equatable {
    case boom
}

@MainActor
final class MockAuthService: AuthServiceProtocol {

    let callLog: CallLog

    var isSignedIn: Bool = false
    var currentProviderKind: AuthProviderKind?
    var signInError: (any Error)?
    var signOutError: (any Error)?
    var restoreResult: Bool = false

    private(set) var signInKinds: [AuthProviderKind] = []
    private(set) var signOutCallCount = 0
    private(set) var restoreCallCount = 0

    init(callLog: CallLog = CallLog()) {
        self.callLog = callLog
    }

    func start() {}
    func addStateObserver(_ observer: any AuthStateObserving) {}
    func removeStateObserver(_ observer: any AuthStateObserving) {}
    func handle(_ url: URL) -> Bool { false }

    func signIn(
        with kind: AuthProviderKind,
        presenting viewController: UIViewController
    ) async throws {
        callLog.append("auth.signIn")
        signInKinds.append(kind)
        if let signInError {
            throw signInError
        }
        isSignedIn = true
    }

    func signOut() throws {
        callLog.append("auth.signOut")
        signOutCallCount += 1
        if let signOutError {
            throw signOutError
        }
        isSignedIn = false
    }

    func restorePreviousSignIn() async -> Bool {
        callLog.append("auth.restore")
        restoreCallCount += 1
        return restoreResult
    }
}

final class MockPushService: PushServiceProtocol {

    let callLog: CallLog
    var error: (any Error)?
    var deleteTokenError: (any Error)?
    private(set) var callCount = 0
    private(set) var deleteTokenCallCount = 0

    init(callLog: CallLog = CallLog()) {
        self.callLog = callLog
    }

    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?) {}

    @discardableResult
    func requestAuthorizationForNotifications() async throws -> Bool {
        callLog.append("push.requestAuthorization")
        callCount += 1
        if let error {
            throw error
        }
        return true
    }

    func deletePushToken() async throws {
        callLog.append("push.deleteToken")
        deleteTokenCallCount += 1
        if let deleteTokenError {
            throw deleteTokenError
        }
    }
}

final class MockSessionMyTBA: MyTBAProtocol {

    let callLog: CallLog
    var unregisterError: (any Error)?
    private(set) var unregisterCallCount = 0

    init(callLog: CallLog = CallLog()) {
        self.callLog = callLog
    }

    /// `MyTBABaseResponse`'s memberwise init is internal to MyTBAKit, so build
    /// one the way the real client does - by decoding.
    private static func baseResponse() throws -> MyTBABaseResponse {
        let json = Data(#"{"code": 200, "message": ""}"#.utf8)
        return try JSONDecoder().decode(MyTBABaseResponse.self, from: json)
    }

    func unregister() async throws -> MyTBABaseResponse {
        callLog.append("myTBA.unregister")
        unregisterCallCount += 1
        if let unregisterError {
            throw unregisterError
        }
        return try Self.baseResponse()
    }

    func ping() async throws -> MyTBABaseResponse {
        return try Self.baseResponse()
    }

    func register() async throws -> MyTBABaseResponse {
        return try Self.baseResponse()
    }

    var favorites: [MyTBAFavorite] = []
    var subscriptions: [MyTBASubscription] = []

    func fetchFavorites() async throws -> [MyTBAFavorite] { favorites }
    func fetchSubscriptions() async throws -> [MyTBASubscription] { subscriptions }

    func updatePreferences(
        modelKey: String,
        modelType: MyTBAModelType,
        favorite: Bool,
        notifications: [NotificationType]
    ) async throws -> MyTBAPreferencesMessageResponse {
        throw MockError.boom
    }
}

final class MockReporter: Reporter {
    private(set) var errors: [any Error] = []
    private(set) var messages: [String] = []

    func record(_ error: any Error) {
        errors.append(error)
    }

    func log(_ message: String) {
        messages.append(message)
    }
}
