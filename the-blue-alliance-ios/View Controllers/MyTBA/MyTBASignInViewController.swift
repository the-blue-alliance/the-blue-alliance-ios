import AuthenticationServices
import Foundation
import UIKit

class MyTBASignInViewController: UIViewController {

    private let authDelegate: AuthDelegate

    @IBOutlet var starImageView: UIImageView! {
        didSet {
            starImageView.tintColor = UIColor.myTBAStarColor
        }
    }
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var favoriteImageView: UIImageView!
    @IBOutlet var subscriptionImageView: UIImageView!
    @IBOutlet var signInButton: UIButton!
    var signInWithAppleButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton(type: .default, style: .whiteOutline)

    init(authDelegate: AuthDelegate) {
        self.authDelegate = authDelegate

        super.init(nibName: String(describing: type(of: self)), bundle: Bundle.main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let newStackViewSpacing: CGFloat = shouldHideImages ? 8.0 : 20.0
        let images = [starImageView, favoriteImageView, subscriptionImageView].filter({ $0.isHidden != shouldHideImages })
        coordinator.animate(alongsideTransition: { [weak self] (_) in
            images.forEach {
                $0.alpha = newImageAlpha
                $0.isHidden = shouldHideImages
            }
            self?.stackView.spacing = newStackViewSpacing
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

        stackView.addArrangedSubview(signInWithAppleButton)
        signInWithAppleButton.autoMatch(.width, to: .width, of: signInButton)
        signInWithAppleButton.autoMatch(.height, to: .height, of: signInButton)
        signInWithAppleButton.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)

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

    @objc private func signInWithApple() {
        authDelegate.startSignInWithAppleFlow()
    }

    @IBAction private func signInWithGoogle() {
        authDelegate.startSignInWithGoogleFlow()
    }

}
