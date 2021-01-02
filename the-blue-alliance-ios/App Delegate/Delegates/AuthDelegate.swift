import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn
import MyTBAKit
import TBAUtils

class AuthDelegate: NSObject {

    private let auth: Auth
    private let myTBA: MyTBA
    private let googleSignIn: GIDSignIn
    private let errorRecorder: ErrorRecorder

    public var presentingViewController: (ContainerViewController & Alertable)? {
        didSet {
            googleSignIn.presentingViewController = presentingViewController
        }
    }

    init(app: FirebaseApp? = FirebaseApp.app(), auth: Auth = Auth.auth(), googleSignIn: GIDSignIn = GIDSignIn.sharedInstance(), errorRecorder: ErrorRecorder, myTBA: MyTBA) {
        self.auth = auth
        self.googleSignIn = googleSignIn
        self.errorRecorder = errorRecorder
        self.myTBA = myTBA

        // Setup Sign In with Google
        if let clientID = app?.options.clientID {
            googleSignIn.clientID = clientID
        } else if let clientID = AuthDelegate.clientIDfromPlist(bundle: Bundle.main) {
            googleSignIn.clientID = clientID
        }

        super.init()

        // Register our myTBA object with Firebase Auth listener
        auth.addIDTokenDidChangeListener { [weak self] (_, user) in
            if let user = user {
                user.getIDToken(completion: { (token, _) in
                    self?.myTBA.authToken = token
                })
            } else {
                self?.myTBA.authToken = nil
            }
        }

        // Register a listener for Apple ID account changes
        let name = ASAuthorizationAppleIDProvider.credentialRevokedNotification
        NotificationCenter.default.addObserver(self, selector: #selector(signInWithAppleRevoked), name: name, object: nil)

        googleSignIn.delegate = self
    }

    // MARK: - Public Methods

    public func startSignInWithGoogleFlow() {
        googleSignIn.signIn()
    }

    public func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    public func signOut() {
        do {
            try auth.signOut()
        } catch {
            if let presentingViewController = presentingViewController {
                presentingViewController.showErrorAlert(with: "Error signing out - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Methods

    private func signInWithCredentials(credential: AuthCredential) {
        auth.signIn(with: credential) { [weak self] (_, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorRecorder.record(error)
                if let presentingViewController = self.presentingViewController {
                    presentingViewController.showErrorAlert(with: "Error signing in to Firebase - \(error.localizedDescription)")
                }
            } else {
                PushService.requestAuthorizationForNotifications { (_, error) in
                    if let error = error {
                        self.errorRecorder.record(error)
                    }
                }
            }
        }
    }

    // MARK: - Sign In with Google

    public func handle(url: URL) -> Bool {
        return googleSignIn.handle(url)
    }

    private static func clientIDfromPlist(bundle: Bundle) -> String? {
        guard let path = bundle.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let result = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] else {
            return nil
        }
        return result["CLIENT_ID"] as? String ?? nil
    }

    // MARK: - Sign In with Apple

    fileprivate var currentNonce: String?

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    // Taken from https://firebase.google.com/docs/auth/ios/apple
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    @objc private func signInWithAppleRevoked(notification: Notification) {
        // Three things have to happen here
        // First, we need to unregister for push notifications from this device
        // This fucking sucks and needs to be some unregistered endpoint, but whatever
        // 
        signOut()
    }

}

extension AuthDelegate: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // Don't respond to a user cancelling a sign in
        if let error = error as NSError?, error.code == GIDSignInErrorCode.canceled.rawValue {
            return
        } else if let error = error {
            errorRecorder.record(error)
            if let presentingViewController = presentingViewController {
                presentingViewController.showErrorAlert(with: "Error signing in to Google - \(error.localizedDescription)")
            }
            return
        }

        guard let authentication = user.authentication else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        signInWithCredentials(credential: credential)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Pass
        print("Signed out of Google")
    }

}

extension AuthDelegate: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            signInWithCredentials(credential: credential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Don't respond to a user cancelling a sign in
        if let error = error as NSError?, error.code == ASAuthorizationError.canceled.rawValue {
            return
        } else {
            errorRecorder.record(error)
            if let presentingViewController = presentingViewController {
                presentingViewController.showErrorAlert(with: "Error signing in to Apple - \(error.localizedDescription)")
            }
        }
    }

}

extension AuthDelegate: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }

}
