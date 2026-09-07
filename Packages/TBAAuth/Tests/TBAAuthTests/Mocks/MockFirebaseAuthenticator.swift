import FirebaseAuth
import Foundation

@testable import TBAAuth

@MainActor
final class MockFirebaseAuthenticator: FirebaseAuthenticating {

    /// Shared with the mock providers so tests can assert cross-object ordering.
    var callLog: CallLog

    var isSignedIn: Bool
    var currentProviderID: String?
    var signInError: Error?
    var signOutError: Error?

    private(set) var signInCredentials: [AuthCredential] = []
    private(set) var listenerCount = 0
    private var listener: ((Bool) -> Void)?

    init(
        callLog: CallLog = CallLog(),
        isSignedIn: Bool = false,
        currentProviderID: String? = nil
    ) {
        self.callLog = callLog
        self.isSignedIn = isSignedIn
        self.currentProviderID = currentProviderID
    }

    func signIn(with credential: AuthCredential) async throws {
        callLog.append("firebase.signIn")
        signInCredentials.append(credential)
        if let signInError {
            throw signInError
        }
        isSignedIn = true
    }

    func signOut() throws {
        callLog.append("firebase.signOut")
        if let signOutError {
            throw signOutError
        }
        isSignedIn = false
        currentProviderID = nil
    }

    func startListening(_ listener: @escaping (Bool) -> Void) {
        listenerCount += 1
        self.listener = listener
    }

    func stopListening() {
        listener = nil
    }

    /// Simulates Firebase reporting an auth state change.
    func fireStateChange(isSignedIn: Bool) {
        listener?(isSignedIn)
    }
}

/// Ordered record of calls across mocks.
@MainActor
final class CallLog {
    private(set) var entries: [String] = []

    func append(_ entry: String) {
        entries.append(entry)
    }
}

enum TestError: Error, Equatable {
    case boom
}
