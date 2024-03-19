import AuthenticationServices
import CryptoKit
import GoogleSignIn
import FirebaseAuth
import Foundation
import TBAUtils
import UIKit

protocol SignInViewControllerDelegate: AnyObject {
    func signInError(error: Error)
    func pushRegistrationError(error: Error)
}

class MyTBASignInViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {

    @IBOutlet var starImageView: UIImageView! {
        didSet {
            starImageView.tintColor = UIColor.myTBAStarColor
        }
    }
    @IBOutlet var favoriteImageView: UIImageView!
    @IBOutlet var subscriptionImageView: UIImageView!
    @IBOutlet var signInButton: UIButton!

    weak var delegate: SignInViewControllerDelegate?

    // Unhashed nonce.
    fileprivate var currentNonce: String?

    init() {
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        // Show/hide our images for compact size classes
        let shouldHideImages = newCollection.verticalSizeClass == .compact
        let newImageAlpha: CGFloat = shouldHideImages ? 0.0 : 1.0
        let images = [starImageView, favoriteImageView, subscriptionImageView].filter({ $0.isHidden != shouldHideImages })
        coordinator.animate(alongsideTransition: { (_) in
            images.forEach {
                $0.alpha = newImageAlpha
                $0.isHidden = shouldHideImages
            }
        })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateInterface(previousTraitCollection: previousTraitCollection)
    }

    // MARK: - Interface Methods

    private func styleInterface() {
        view.backgroundColor = UIColor.systemGroupedBackground
        signInButton.setTitleColor(UIColor.googleSignInTextColor, for: .normal)

        updateInterface(previousTraitCollection: nil)
    }

    private func updateInterface(previousTraitCollection: UITraitCollection?) {
        if let previousTraitCollection = previousTraitCollection, previousTraitCollection.userInterfaceStyle != traitCollection.userInterfaceStyle {
            // There's some bug (or - possibly misconfigured on my part) with stretching + the trait collection changing.
            // As a workaround, we need to manually reset all the background images for the sign in button
            signInButton.setBackgroundImage(UIImage(named: "btn_google_signin_normal"), for: .normal)
            signInButton.setBackgroundImage(UIImage(named: "btn_google_signin_pressed"), for: .selected)
            signInButton.setBackgroundImage(UIImage(named: "btn_google_signin_focus"), for: .focused)
            signInButton.setBackgroundImage(UIImage(named: "btn_google_signin_disabled"), for: .disabled)
        }
    }

    // MARK: - IBActions

    @IBAction private func signIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            // Don't respond to errors from signInSilently or a user cancelling a sign in
            if let error = error as NSError?, error.code == GIDSignInError.canceled.rawValue {
                return
            } else if let error = error {
                self.delegate?.signInError(error: error)
                return
            }

            AuthHelper.signInToGoogle(user: result?.user) { [unowned self] success, error in
                if let error = error {
                    delegate?.signInError(error: error)
                }
                guard success else {
                    return
                }
                PushService.requestAuthorizationForNotifications { [unowned self] (_, error) in
                    guard let error = error else {
                        return
                    }
                    delegate?.pushRegistrationError(error: error)
                }
            }
        }
    }

    // https://firebase.google.com/docs/auth/ios/apple

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    @IBAction private func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

}

extension MyTBASignInViewController: ASAuthorizationControllerDelegate {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

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
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }

                // TODO: Need to do something here......
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }

}
