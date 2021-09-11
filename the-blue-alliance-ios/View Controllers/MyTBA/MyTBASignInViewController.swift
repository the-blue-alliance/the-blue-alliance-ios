import Foundation
import UIKit
import GoogleSignIn

class MyTBASignInViewController: UIViewController {

    @IBOutlet var starImageView: UIImageView! {
        didSet {
            starImageView.tintColor = UIColor.myTBAStarColor
        }
    }
    @IBOutlet var favoriteImageView: UIImageView!
    @IBOutlet var subscriptionImageView: UIImageView!
    @IBOutlet var signInButton: UIButton!

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
        // TODO: We need a clientID here
        // guard let clientID = clientID else { return }
        let configuration = GIDConfiguration(clientID: "")
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: self) { user, error in
            guard error == nil else { return }

            // If sign in succeeded, display the app's main content View.
        }
    }

}
