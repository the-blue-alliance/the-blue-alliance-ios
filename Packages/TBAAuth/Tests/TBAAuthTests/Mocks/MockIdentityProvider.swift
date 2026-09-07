import FirebaseAuth
import TBAUtils
import UIKit

@testable import TBAAuth

@MainActor
final class MockIdentityProvider: IdentityProviding {

    let kind: AuthProviderKind
    let callLog: CallLog

    var credentialError: Error?
    var restoreError: Error?
    var restoredCredential: AuthCredential?

    private(set) var credentialCallCount = 0
    private(set) var restoreCallCount = 0
    private(set) var signOutCallCount = 0
    private(set) var handledURLs: [URL] = []
    var handlesURLs = false

    init(kind: AuthProviderKind, callLog: CallLog = CallLog()) {
        self.kind = kind
        self.callLog = callLog
    }

    /// A credential is a plain value object - building one needs no configured
    /// FirebaseApp and makes no network calls.
    static func stubCredential() -> AuthCredential {
        return GoogleAuthProvider.credential(withIDToken: "id-token", accessToken: "access-token")
    }

    func credential(presenting viewController: UIViewController) async throws -> AuthCredential {
        callLog.append("\(kind.rawValue).credential")
        credentialCallCount += 1
        if let credentialError {
            throw credentialError
        }
        return Self.stubCredential()
    }

    func restoreCredential() async throws -> AuthCredential? {
        callLog.append("\(kind.rawValue).restoreCredential")
        restoreCallCount += 1
        if let restoreError {
            throw restoreError
        }
        return restoredCredential
    }

    func signOut() {
        callLog.append("\(kind.rawValue).signOut")
        signOutCallCount += 1
    }

    func handle(_ url: URL) -> Bool {
        handledURLs.append(url)
        return handlesURLs
    }
}

@MainActor
final class MockAuthStateObserver: AuthStateObserving {
    private(set) var states: [Bool] = []

    func authStateChanged(isSignedIn: Bool) {
        states.append(isSignedIn)
    }
}

final class MockReporter: Reporter {
    private(set) var errors: [Error] = []
    private(set) var messages: [String] = []

    func record(_ error: Error) {
        errors.append(error)
    }

    func log(_ message: String) {
        messages.append(message)
    }
}
