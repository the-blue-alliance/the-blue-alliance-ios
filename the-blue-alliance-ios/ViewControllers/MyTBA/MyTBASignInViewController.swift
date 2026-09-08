import PureLayout
import TBAAuth
import UIKit

protocol SignInViewControllerDelegate: AnyObject {
    func signInViewController(_ controller: MyTBASignInViewController, didFailWith error: any Error)
}

class MyTBASignInViewController: UIViewController {

    weak var delegate: (any SignInViewControllerDelegate)?

    private let dependencies: Dependencies

    private var isSigningIn: Bool = false {
        didSet {
            googleSignInButton.isEnabled = !isSigningIn
            appleSignInButton.isEnabled = !isSigningIn
        }
    }

    // MARK: - View Elements

    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.myTBAStarColor
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to myTBA"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var favoriteImageView = Self.featureImageView(systemName: "heart")
    private lazy var subscriptionImageView = Self.featureImageView(systemName: "bell")

    private lazy var googleSignInButton: UIControl = {
        let button = SignInButton.google()
        button.addAction(
            UIAction { [weak self] _ in self?.beginSignIn(with: .google) },
            for: .touchUpInside
        )
        return button
    }()

    // Style is baked in at init, so a light/dark change means a new button.
    private lazy var appleSignInButton: UIControl = makeAppleSignInButton()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [googleSignInButton, appleSignInButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let headerStackView = UIStackView(arrangedSubviews: [starImageView, titleLabel])
        headerStackView.axis = .vertical
        headerStackView.alignment = .center
        headerStackView.spacing = 8

        let stackView = UIStackView(arrangedSubviews: [
            headerStackView,
            Self.featureRow(
                imageView: favoriteImageView,
                text: "Mark teams, events, and matches as favorites for fast access"
            ),
            Self.featureRow(
                imageView: subscriptionImageView,
                text: "Subscribe to teams, events, and matches to get realtime updates"
            ),
            buttonsStackView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (self: Self, _: UITraitCollection) in
            self.replaceAppleSignInButton()
        }
    }

    // A tab bar controller only forwards transitions to its selected child, so
    // a tab that rotated while off screen never got willTransition. Re-apply on
    // the way back; when nothing changed this is a no-op.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyImageVisibility(for: traitCollection)
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.applyImageVisibility(for: newCollection)
        }
    }

    // MARK: - Interface Methods

    private func styleInterface() {
        view.backgroundColor = UIColor.systemGroupedBackground

        view.addSubview(contentStackView)
        for edge in [ALEdge.leading, ALEdge.trailing] {
            contentStackView.autoPinEdge(toSuperviewSafeArea: edge, withInset: 20)
        }
        contentStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        contentStackView.autoPinEdge(
            toSuperviewSafeArea: .top,
            withInset: 0,
            relation: .greaterThanOrEqual
        )
        contentStackView.autoPinEdge(
            toSuperviewSafeArea: .bottom,
            withInset: 0,
            relation: .greaterThanOrEqual
        )

        // ASAuthorizationAppleIDButton caps itself at 375pt, so the pair fills
        // the width in portrait and sits centered at 375 in landscape.
        buttonsStackView.autoSetDimension(.width, toSize: 375, relation: .lessThanOrEqual)
        let fill = buttonsStackView.autoMatch(.width, to: .width, of: contentStackView)
        fill.priority = .defaultHigh
        starImageView.autoSetDimension(.height, toSize: 60)
        starImageView.autoMatch(
            .width,
            to: .height,
            of: starImageView,
            withMultiplier: 102.0 / 97.0
        )
        googleSignInButton.autoSetDimension(.height, toSize: 48)
        appleSignInButton.autoSetDimension(.height, toSize: 48)
    }

    private func applyImageVisibility(for traitCollection: UITraitCollection) {
        let shouldHideImages = traitCollection.verticalSizeClass == .compact
        for imageView in [starImageView, favoriteImageView, subscriptionImageView]
        where imageView.isHidden != shouldHideImages {
            imageView.alpha = shouldHideImages ? 0 : 1
            imageView.isHidden = shouldHideImages
        }
    }

    private func makeAppleSignInButton() -> UIControl {
        let button = SignInButton.apple(for: traitCollection.userInterfaceStyle)
        button.isEnabled = !isSigningIn
        button.addAction(
            UIAction { [weak self] _ in self?.beginSignIn(with: .apple) },
            for: .touchUpInside
        )
        return button
    }

    private func replaceAppleSignInButton() {
        let previous = appleSignInButton
        let index = buttonsStackView.arrangedSubviews.firstIndex(of: previous) ?? 0
        buttonsStackView.removeArrangedSubview(previous)
        previous.removeFromSuperview()

        appleSignInButton = makeAppleSignInButton()
        buttonsStackView.insertArrangedSubview(appleSignInButton, at: index)
        appleSignInButton.autoSetDimension(.height, toSize: 48)
    }

    // MARK: - Sign In

    private func beginSignIn(with kind: AuthProviderKind) {
        guard !isSigningIn else {
            return
        }
        isSigningIn = true

        Task {
            defer { isSigningIn = false }
            do {
                try await dependencies.myTBASession.signIn(with: kind, presenting: self)
            } catch {
                delegate?.signInViewController(self, didFailWith: error)
            }
        }
    }

    // MARK: - View Factories

    private static func featureImageView(systemName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.label
        imageView.autoSetDimensions(to: CGSize(width: 28, height: 28))
        return imageView
    }

    private static func featureRow(imageView: UIImageView, text: String) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }

}
