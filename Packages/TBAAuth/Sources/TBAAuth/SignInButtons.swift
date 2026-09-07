import AuthenticationServices
import GoogleSignIn
import UIKit

@MainActor
public enum SignInButton {

    public static func google(for userInterfaceStyle: UIUserInterfaceStyle) -> UIControl {
        let button = GIDSignInButton()
        button.style = .wide
        button.colorScheme = userInterfaceStyle == .dark ? .dark : .light
        return button
    }

    public static func apple(for userInterfaceStyle: UIUserInterfaceStyle) -> UIControl {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: userInterfaceStyle == .dark ? .white : .black
        )
        button.cornerRadius = 4
        return button
    }
}
