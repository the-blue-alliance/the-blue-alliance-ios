import Foundation
import UIKit
import GoogleSignIn

class MyTBASignInViewController: UIViewController {
    
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var favoriteImageView: UIImageView!
    @IBOutlet var subscriptionImageView: UIImageView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideOrShowImageViews(for: traitCollection)

        super.viewWillAppear(animated)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        hideOrShowImageViews(for: newCollection)

        super.willTransition(to: newCollection, with: coordinator)
    }
    
    func styleInterface() {
        view.backgroundColor = .backgroundGray
    }

    func hideOrShowImageViews(for traitCollection: UITraitCollection) {
        // Hide our images for compact size classes
        for image in [starImageView, favoriteImageView, subscriptionImageView] {
            image?.isHidden = (traitCollection.verticalSizeClass == .compact)
        }
    }
    
    // MARK: - IBActions

    @IBAction func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }

}
