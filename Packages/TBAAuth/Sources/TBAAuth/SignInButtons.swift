import AuthenticationServices
import UIKit

/// Provider-branded buttons, so callers never import a provider SDK to draw one.
@MainActor
public enum SignInButton {

    /// Built to Google's sign-in branding spec rather than `GIDSignInButton`, which
    /// draws itself with a shadow, an inset, and Roboto and can't be restyled to
    /// sit next to Apple's. Dark in light mode and light in dark mode, so the
    /// pair always match.
    public static func google() -> UIControl {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(named: "google", in: .module, with: nil)
        configuration.imagePadding = 8
        configuration.attributedTitle = AttributedString(
            "Sign in with Google",
            attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 19, weight: .semibold)]
            )
        )
        configuration.baseBackgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : UIColor(white: 0x13 / 255, alpha: 1)
        }
        configuration.baseForegroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0x1F / 255, alpha: 1) : UIColor(white: 0xE3 / 255, alpha: 1)
        }
        configuration.background.cornerRadius = 4
        configuration.cornerStyle = .fixed
        return UIButton(configuration: configuration)
    }

    /// Style is fixed at init, so a light/dark change means a new button.
    public static func apple(for userInterfaceStyle: UIUserInterfaceStyle) -> UIControl {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: userInterfaceStyle == .dark ? .white : .black
        )
        button.cornerRadius = 4
        return button
    }
}
