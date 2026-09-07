import Testing
import UIKit

@testable import TBAAuth

@MainActor
struct AuthServiceTests {

    let callLog = CallLog()
    let reporter = MockReporter()
    let firebase: MockFirebaseAuthenticator
    let google: MockIdentityProvider
    let apple: MockIdentityProvider
    let service: AuthService

    init() {
        firebase = MockFirebaseAuthenticator(callLog: callLog)
        google = MockIdentityProvider(kind: .google, callLog: callLog)
        apple = MockIdentityProvider(kind: .apple, callLog: callLog)
        service = AuthService(firebase: firebase, providers: [google, apple], reporter: reporter)
    }

    // MARK: - Sign in

    @Test func signIn_google_usesOnlyTheGoogleProvider() async throws {
        try await service.signIn(with: .google, presenting: UIViewController())

        #expect(google.credentialCallCount == 1)
        #expect(apple.credentialCallCount == 0)
        #expect(firebase.signInCredentials.count == 1)
    }

    @Test func signIn_apple_usesOnlyTheAppleProvider() async throws {
        try await service.signIn(with: .apple, presenting: UIViewController())

        #expect(apple.credentialCallCount == 1)
        #expect(google.credentialCallCount == 0)
        #expect(firebase.signInCredentials.count == 1)
    }

    @Test func signIn_unsupportedProvider_throws() async {
        let service = AuthService(firebase: firebase, providers: [google], reporter: reporter)

        await #expect(throws: AuthError.unsupportedProvider(.apple)) {
            try await service.signIn(with: .apple, presenting: UIViewController())
        }
    }

    @Test func signIn_canceled_propagatesAndSkipsFirebase() async {
        google.credentialError = AuthError.canceled

        await #expect(throws: AuthError.canceled) {
            try await service.signIn(with: .google, presenting: UIViewController())
        }
        #expect(firebase.signInCredentials.isEmpty)
    }

    // MARK: - Sign out

    // A provider left signed in is one `restorePreviousSignIn` would silently
    // revive on the next launch, so sign-out covers all of them.
    @Test func signOut_signsOutOfEveryProvider() throws {
        firebase.isSignedIn = true
        firebase.currentProviderID = "apple.com"

        try service.signOut()

        #expect(apple.signOutCallCount == 1)
        #expect(google.signOutCallCount == 1)
    }

    @Test func signOut_signsOutOfFirebaseFirst() throws {
        firebase.isSignedIn = true
        firebase.currentProviderID = "google.com"

        try service.signOut()

        #expect(callLog.entries.first == "firebase.signOut")
        #expect(callLog.entries.count == 3)
    }

    @Test func signOut_firebaseFailure_propagatesAndSkipsProviders() {
        firebase.isSignedIn = true
        firebase.currentProviderID = "google.com"
        firebase.signOutError = TestError.boom

        #expect(throws: TestError.boom) {
            try service.signOut()
        }
        #expect(google.signOutCallCount == 0)
        #expect(apple.signOutCallCount == 0)
    }

    // MARK: - Restore

    @Test func restore_whenAlreadySignedIn_doesNothing() async {
        firebase.isSignedIn = true

        let restored = await service.restorePreviousSignIn()

        #expect(!restored)
        #expect(google.restoreCallCount == 0)
        #expect(apple.restoreCallCount == 0)
    }

    @Test func restore_withNothingToRestore_returnsFalse() async {
        let restored = await service.restorePreviousSignIn()

        #expect(!restored)
        #expect(google.restoreCallCount == 1)
        #expect(firebase.signInCredentials.isEmpty)
    }

    @Test func restore_signsInWithTheRestoredCredential() async {
        google.restoredCredential = MockIdentityProvider.stubCredential()

        let restored = await service.restorePreviousSignIn()

        #expect(restored)
        #expect(firebase.signInCredentials.count == 1)
    }

    @Test func restore_reportsProviderErrorAndTriesTheNextProvider() async {
        google.restoreError = TestError.boom
        apple.restoredCredential = MockIdentityProvider.stubCredential()

        let restored = await service.restorePreviousSignIn()

        #expect(restored)
        #expect(reporter.errors.count == 1)
        #expect(apple.restoreCallCount == 1)
    }

    // MARK: - State observation

    @Test func start_attachesASingleListener() {
        service.start()
        service.start()

        #expect(firebase.listenerCount == 1)
    }

    @Test func observersReceiveStateChanges() {
        let observer = MockAuthStateObserver()
        service.addStateObserver(observer)
        service.start()

        firebase.fireStateChange(isSignedIn: true)
        firebase.fireStateChange(isSignedIn: false)

        #expect(observer.states == [true, false])
    }

    @Test func addingTheSameObserverTwiceDoesNotDoublePost() {
        let observer = MockAuthStateObserver()
        service.addStateObserver(observer)
        service.addStateObserver(observer)
        service.start()

        firebase.fireStateChange(isSignedIn: true)

        #expect(observer.states == [true])
    }

    @Test func removedObserverStopsReceivingUpdates() {
        let observer = MockAuthStateObserver()
        service.addStateObserver(observer)
        service.start()
        service.removeStateObserver(observer)

        firebase.fireStateChange(isSignedIn: true)

        #expect(observer.states.isEmpty)
    }

    @Test func observersAreHeldWeakly() {
        var observer: MockAuthStateObserver? = MockAuthStateObserver()
        service.addStateObserver(observer!)
        service.start()

        observer = nil
        // Nothing to assert beyond "this doesn't crash on a zeroed reference".
        firebase.fireStateChange(isSignedIn: true)
    }

    // MARK: - Derived state

    @Test func currentProviderKind_mapsFirebaseProviderIDs() {
        firebase.currentProviderID = "google.com"
        #expect(service.currentProviderKind == .google)

        firebase.currentProviderID = "apple.com"
        #expect(service.currentProviderKind == .apple)

        firebase.currentProviderID = "password"
        #expect(service.currentProviderKind == nil)

        firebase.currentProviderID = nil
        #expect(service.currentProviderKind == nil)
    }

    // MARK: - URL handling

    @Test func handle_returnsTrueWhenAProviderClaimsTheURL() {
        google.handlesURLs = true
        #expect(service.handle(URL(string: "com.example://callback")!))
    }

    @Test func handle_returnsFalseWhenNoProviderClaimsTheURL() {
        #expect(!service.handle(URL(string: "com.example://callback")!))
    }
}
